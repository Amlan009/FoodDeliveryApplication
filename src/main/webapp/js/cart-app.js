/**
 * Khaalo Cart AJAX & Interactivity Engine
 */

document.addEventListener('DOMContentLoaded', () => {
    initToastContainer();
    initCartFormInterception();
    initButtonRipples();
});

// Initialize Toast Notification Container
function initToastContainer() {
    if (!document.getElementById('toast-container')) {
        const container = document.createElement('div');
        container.id = 'toast-container';
        document.body.appendChild(container);
    }
}

// Display Toast Notification
window.showToast = function(message, isError = false) {
    initToastContainer();
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `khaalo-toast ${isError ? 'error' : ''}`;
    toast.innerHTML = `
        <span>${isError ? '⚠️' : '✨'}</span>
        <span>${message}</span>
    `;
    container.appendChild(toast);

    setTimeout(() => {
        toast.classList.add('fade-out');
        setTimeout(() => toast.remove(), 300);
    }, 3000);
};

// Intercept form submissions & button clicks targeting CartServlet
function initCartFormInterception() {
    const handleCartAction = (e, form, btn) => {
        const actionUrl = form.getAttribute('action') || form.action || '';
        if (!actionUrl.includes('CartServlet') && !actionUrl.includes('cart')) return;

        if (form._isProcessingCartAction) {
            e.preventDefault();
            e.stopPropagation();
            return;
        }
        form._isProcessingCartAction = true;
        setTimeout(() => { try { delete form._isProcessingCartAction; } catch(err){} }, 500);

        const formData = new FormData(form);
        const actionType = formData.get('action');
        if (actionType === 'update') return;

        e.preventDefault();
        e.stopPropagation();

        const dishId = formData.get('dishId');
        const quantityDelta = parseInt(formData.get('quantity') || '1', 10);
        const resId = formData.get('restaurantId') || '';
        const isConfirmReplace = formData.get('confirmReplace') === 'true';

        // Check for client-side conflict BEFORE updating stepper or fetching
        if (!isConfirmReplace && quantityDelta > 0 && resId && window.currentCartRestaurantId && window.currentCartRestaurantId !== resId && window.currentCartSize > 0) {
            const card = btn ? btn.closest('.recommended-card, .trending-card, .dish-card, .menu-item-card') : null;
            const dishName = card ? (card.getAttribute('data-name') || card.querySelector('h4, .dish-name, h3')?.innerText || 'Selected Dish') : 'Selected Dish';
            
            let newPrice = 0;
            if (card) {
                const priceAttr = card.getAttribute('data-price');
                if (priceAttr) {
                    newPrice = parseFloat(priceAttr);
                } else {
                    const priceElem = card.querySelector('.price');
                    if (priceElem) {
                        newPrice = parseFloat(priceElem.innerText.replace(/[^0-9.]/g, ''));
                    }
                }
            }

            showCartConflictModal({
                newDishId: dishId,
                newRestaurantId: resId,
                dishName: dishName,
                newPrice: newPrice
            });
            return;
        }

        if (isConfirmReplace) {
            // Confirm replace handles cart reset on server. Reset local cart size state.
            window.currentCartSize = 0;
            window.cartItems = [];
        } else {
            // Update local window.cartItems array
            if (!window.cartItems) window.cartItems = [];
            let itemIndex = window.cartItems.findIndex(i => String(i.dishId) === String(dishId));
            if (itemIndex > -1) {
                window.cartItems[itemIndex].quantity += quantityDelta;
                if (window.cartItems[itemIndex].quantity <= 0) {
                    window.cartItems.splice(itemIndex, 1);
                }
            } else if (quantityDelta > 0) {
                let price = 0;
                const card = form.closest('.recommended-card, .trending-card, .dish-card, .menu-item-card');
                if (card) {
                    const priceAttr = card.getAttribute('data-price');
                    if (priceAttr) {
                        price = parseFloat(priceAttr);
                    } else {
                        const priceElem = card.querySelector('.price');
                        if (priceElem) {
                            price = parseFloat(priceElem.innerText.replace(/[^0-9.]/g, ''));
                        }
                    }
                }
                window.cartItems.push({
                    dishId: parseInt(dishId),
                    quantity: quantityDelta,
                    price: price
                });
            }

            // NO CONFLICT -> Proceed with instant optimistic DOM update
            if (quantityDelta > 0) {
                animateFlyToCart(btn || form);
            }

            if (window.location.pathname.includes('cart.jsp')) {
                updateCartPageDomLocally(dishId, quantityDelta);
            } else {
                updateDishSteppersLocally(dishId, quantityDelta, resId);
            }

            if (resId && quantityDelta > 0) {
                window.currentCartRestaurantId = resId;
            }
            window.currentCartSize = Math.max(0, (window.currentCartSize || 0) + quantityDelta);

            if (window.updateFloatingCartState) {
                window.updateFloatingCartState();
            }
        }

        sendCartAjaxRequest(actionUrl, formData, actionType, quantityDelta, form);
    };

    document.addEventListener('click', (e) => {
        const btn = e.target.closest('button[type="submit"], .dish-add-btn, .menu-qty-btn');
        if (!btn) return;
        const form = btn.closest('form');
        if (!form) return;
        handleCartAction(e, form, btn);
    });

    document.addEventListener('submit', (e) => {
        const form = e.target;
        const btn = form.querySelector('button[type="submit"]');
        if (form && (form.getAttribute('action') || form.action || '').includes('CartServlet')) {
            handleCartAction(e, form, btn);
        }
    });
}

// Helper to dispatch AJAX POST request for cart modifications
async function sendCartAjaxRequest(actionUrl, formData, actionType, quantityDelta, form) {
    try {
        formData.append('isAjax', 'true');
        const response = await fetch(actionUrl, {
            method: 'POST',
            body: new URLSearchParams(formData),
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            }
        });

        const contentType = response.headers.get('content-type') || '';
        if (contentType.includes('application/json')) {
            const data = await response.json();
            if (data.status === 'conflict') {
                const dishId = formData.get('dishId');
                const resId = formData.get('restaurantId') || '';

                // Revert optimistic stepper update if any
                updateDishSteppersLocally(dishId, -quantityDelta, resId);
                
                // Revert local window.cartItems array update as well
                if (window.cartItems) {
                    let itemIndex = window.cartItems.findIndex(i => String(i.dishId) === String(dishId));
                    if (itemIndex > -1) {
                        window.cartItems[itemIndex].quantity -= quantityDelta;
                        if (window.cartItems[itemIndex].quantity <= 0) {
                            window.cartItems.splice(itemIndex, 1);
                        }
                    }
                }
                
                if (window.updateFloatingCartState) window.updateFloatingCartState();

                let newPrice = 0;
                const card = document.querySelector(`[data-dish-id="${data.newDishId || dishId}"]`)?.closest('.recommended-card, .trending-card, .dish-card, .menu-item-card');
                if (card) {
                    const priceAttr = card.getAttribute('data-price');
                    if (priceAttr) {
                        newPrice = parseFloat(priceAttr);
                    } else {
                        const priceElem = card.querySelector('.price');
                        if (priceElem) {
                            newPrice = parseFloat(priceElem.innerText.replace(/[^0-9.]/g, ''));
                        }
                    }
                }
                data.newPrice = newPrice;

                showCartConflictModal(data);
                return;
            }
        }

        if (response.ok) {
            if (formData.get('confirmReplace') === 'true') {
                const modal = document.getElementById('cartConflictModalOverlay');
                if (modal) {
                    modal.style.display = 'none';
                    modal.classList.remove('active');
                }
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';

                const newDishId = formData.get('dishId');
                const newResId = formData.get('restaurantId') || '';

                // Reset all active steppers on screen to ADD button
                document.querySelectorAll('.homepage-qty-container, .dish-action-container, [data-dish-id]').forEach(c => {
                    const dId = c.getAttribute('data-dish-id') || c.querySelector('input[name="dishId"]')?.value;
                    const rId = c.getAttribute('data-res-id') || '';
                    if (dId) {
                        const spanQty = c.querySelector('span:not(.customisable-tag)');
                        if (spanQty) {
                            updateDishSteppersLocally(dId, -9999, rId);
                        }
                    }
                });

                // Update the new dish stepper to 1
                updateDishSteppersLocally(newDishId, 1, newResId);

                window.currentCartRestaurantId = newResId;
                window.currentCartSize = 1;

                // Sync window.cartItems array
                let newPrice = parseFloat(formData.get('newPrice') || '0');
                if (newPrice === 0) {
                    const card = form ? form.closest('.recommended-card, .trending-card, .dish-card, .menu-item-card') : null;
                    if (card) {
                        const priceAttr = card.getAttribute('data-price');
                        if (priceAttr) {
                            newPrice = parseFloat(priceAttr);
                        } else {
                            const priceElem = card.querySelector('.price');
                            if (priceElem) {
                                newPrice = parseFloat(priceElem.innerText.replace(/[^0-9.]/g, ''));
                            }
                        }
                    }
                }
                window.cartItems = [{
                    dishId: parseInt(newDishId),
                    quantity: 1,
                    price: newPrice
                }];

                if (window.updateFloatingCartState) window.updateFloatingCartState();

                showToast('Replaced cart with new restaurant items!');
                return;
            }

            if (actionType === 'add') {
                if (quantityDelta > 0) {
                    showToast('Added item to your cart!');
                } else {
                    showToast('Updated item quantity.');
                }
            } else if (actionType === 'delete' || actionType === 'clear') {
                if (actionType === 'clear') {
                    window.cartItems = [];
                } else {
                    const deletedDishId = formData.get('dishId');
                    if (deletedDishId && window.cartItems) {
                        window.cartItems = window.cartItems.filter(i => String(i.dishId) !== String(deletedDishId));
                    }
                }
                if (window.updateFloatingCartState) window.updateFloatingCartState();
                showToast('Removed item from cart.');
            }
        }
    } catch (err) {
        console.error('Cart AJAX error:', err);
    }
}

// Display Replace Cart Modal Overlay 100% reliably in real-time
function showCartConflictModal(data) {
    let modal = document.getElementById('cartConflictModalOverlay');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'cartConflictModalOverlay';
        document.body.appendChild(modal);
    } else if (modal.parentElement !== document.body) {
        document.body.appendChild(modal);
    }

    // Try extracting existing dish name from DOM if not present in payload
    let existingDishName = data.existingDishName || '';
    if (!existingDishName) {
        const activeSteppers = document.querySelectorAll('.homepage-qty-container, .dish-action-container, [data-dish-id]');
        activeSteppers.forEach(c => {
            const spanQty = c.querySelector('span:not(.customisable-tag)');
            if (spanQty && parseInt(spanQty.innerText || '0', 10) > 0) {
                const card = c.closest('.dish-card, .menu-item-card, [data-dish-id]');
                if (card) {
                    const nameEl = card.querySelector('.dish-title, .menu-item-name, h3, h4, .dish-name');
                    if (nameEl && !existingDishName) existingDishName = nameEl.innerText.trim();
                }
            }
        });
    }
    if (!existingDishName) existingDishName = 'Item from previous restaurant';

    const newDishName = data.dishName || 'Selected Dish';

    document.body.classList.add('modal-open');
    modal.className = 'modal-overlay active';
    modal.style.cssText = 'position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); display: flex; align-items: center; justify-content: center; z-index: 9999999; padding: 16px; opacity: 1; visibility: visible; pointer-events: auto; overscroll-behavior: contain;';
    
    modal.innerHTML = `
        <div class="modal-container" style="max-width: 420px; width: 90%; background: rgba(255, 255, 255, 0.88); backdrop-filter: blur(30px); -webkit-backdrop-filter: blur(30px); border-radius: 28px; padding: 32px 24px; text-align: center; font-family: Outfit, Inter, Poppins, sans-serif; box-shadow: 0 30px 60px -12px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.9), 0 0 40px rgba(255,107,53,0.15); border: 1px solid rgba(255, 255, 255, 0.8); position: relative; transform: none; animation: modalPop 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);">
            <button type="button" onclick="const m=document.getElementById('cartConflictModalOverlay'); if(m){m.style.display='none'; m.classList.remove('active'); document.body.classList.remove('modal-open');}" style="position: absolute; top: 18px; right: 18px; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.05); border: 1px solid rgba(0, 0, 0, 0.08); font-size: 1.1rem; color: #475569; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.2s ease;">✕</button>
            
            <div style="width: 64px; height: 64px; background: linear-gradient(135deg, #fff0eb 0%, #ffe4d6 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 14px auto; box-shadow: 0 10px 25px rgba(255, 107, 53, 0.25); border: 2px solid #ffffff; position: relative;">
                <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="#ff6b35" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M6 2L3 6v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2V6l-3-4z"></path>
                    <line x1="3" y1="6" x2="21" y2="6"></line>
                    <path d="M16 10a4 4 0 0 1-8 0"></path>
                </svg>
                <div style="position: absolute; bottom: -4px; right: -4px; width: 24px; height: 24px; background: #ff6b35; border-radius: 50%; display: flex; align-items: center; justify-content: center; border: 2px solid #ffffff; box-shadow: 0 2px 6px rgba(0,0,0,0.15);">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#ffffff" stroke-width="3" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="23 4 23 10 17 10"></polyline>
                        <path d="M20.49 15a9 9 0 1 1-2.12-9.36L23 10"></path>
                    </svg>
                </div>
            </div>
            
            <h3 style="font-size: 1.4rem; font-weight: 800; color: #0f172a; margin: 0 0 6px 0; letter-spacing: -0.4px;">Replace Cart Items?</h3>
            <p style="font-size: 0.84rem; color: #64748b; line-height: 1.5; margin: 0 0 20px 0;">
                Your cart contains items from another restaurant. Replace your cart with the new dish?
            </p>

            <div style="display: flex; flex-direction: column; gap: 10px; margin-bottom: 24px; text-align: left;">
                <!-- Existing Cart Item Card -->
                <div style="background: rgba(239, 68, 68, 0.06); border: 1.5px solid rgba(239, 68, 68, 0.2); border-radius: 14px; padding: 12px 14px; display: flex; align-items: center; justify-content: space-between; backdrop-filter: blur(8px);">
                    <div style="overflow: hidden; padding-right: 8px;">
                        <div style="font-size: 0.68rem; font-weight: 800; color: #ef4444; text-transform: uppercase; letter-spacing: 0.6px; margin-bottom: 2px; display: flex; align-items: center; gap: 4px;">
                            <span style="font-size: 0.6rem;">🔴</span> CURRENT CART ITEM
                        </div>
                        <div style="font-size: 0.9rem; font-weight: 800; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${existingDishName}
                        </div>
                    </div>
                    <span style="font-size: 0.7rem; font-weight: 800; color: #ef4444; background: rgba(239, 68, 68, 0.12); padding: 4px 8px; border-radius: 8px; white-space: nowrap; shrink: 0;">Remove</span>
                </div>

                <!-- New Item Card -->
                <div style="background: rgba(37, 197, 120, 0.08); border: 1.5px solid rgba(37, 197, 120, 0.3); border-radius: 14px; padding: 12px 14px; display: flex; align-items: center; justify-content: space-between; backdrop-filter: blur(8px);">
                    <div style="overflow: hidden; padding-right: 8px;">
                        <div style="font-size: 0.68rem; font-weight: 800; color: #16a34a; text-transform: uppercase; letter-spacing: 0.6px; margin-bottom: 2px; display: flex; align-items: center; gap: 4px;">
                            <span style="font-size: 0.6rem;">🟢</span> NEW SELECTION
                        </div>
                        <div style="font-size: 0.9rem; font-weight: 800; color: #1e293b; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                            ${newDishName}
                        </div>
                    </div>
                    <span style="font-size: 0.7rem; font-weight: 800; color: #16a34a; background: rgba(37, 197, 120, 0.15); padding: 4px 8px; border-radius: 8px; white-space: nowrap; shrink: 0;">Add</span>
                </div>
            </div>
            
            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 12px;">
                <button type="button" onclick="const m=document.getElementById('cartConflictModalOverlay'); if(m){m.style.display='none'; m.classList.remove('active'); document.body.classList.remove('modal-open');}" style="padding: 13px 16px; border-radius: 14px; font-weight: 800; border: 1.5px solid rgba(203, 213, 225, 0.8); color: #475569; background: rgba(255, 255, 255, 0.8); cursor: pointer; font-size: 0.88rem; transition: all 0.2s ease;">
                    NO, KEEP
                </button>
                <form action="CartServlet" method="POST" id="conflictConfirmForm" style="margin: 0; padding: 0; display: block;">
                    <input type="hidden" name="action" value="add">
                    <input type="hidden" name="dishId" id="confirmReplaceDishId" value="${data.newDishId || ''}">
                    <input type="hidden" name="restaurantId" id="confirmReplaceRestaurantId" value="${data.newRestaurantId || ''}">
                    <input type="hidden" name="newPrice" id="confirmReplaceNewPrice" value="${data.newPrice || '0'}">
                    <input type="hidden" name="confirmReplace" value="true">
                    <input type="hidden" name="quantity" value="1">
                    <button type="submit" style="width: 100%; padding: 13px 16px; border-radius: 14px; font-weight: 800; border: none; color: white; background: linear-gradient(135deg, #ff6b35 0%, #ea580c 100%); cursor: pointer; font-size: 0.88rem; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.4); transition: all 0.2s ease;">
                        YES, REPLACE
                    </button>
                </form>
            </div>
        </div>
    `;

    modal.style.display = 'flex';
    modal.style.opacity = '1';
    modal.style.visibility = 'visible';
    modal.style.pointerEvents = 'auto';
    modal.classList.add('active');
}

// Dynamically update UI quantity steppers across all dish cards matching dishId instantly
function updateDishSteppersLocally(dishId, delta, resId) {
    if (!dishId) return;

    const isMenuPage = window.location.pathname.includes('menu');
    const currentPageName = isMenuPage ? 'menu.jsp' : 'restaurants.jsp';

    const qtyContainers = document.querySelectorAll('.homepage-qty-container, .dish-action-container, [data-dish-id]');
    qtyContainers.forEach(container => {
        const containerDishId = container.getAttribute('data-dish-id') || 
                                container.querySelector('input[name="dishId"]')?.value;

        if (!containerDishId || String(containerDishId).trim() !== String(dishId).trim()) {
            return;
        }

        const targetResId = resId || container.getAttribute('data-res-id') || '';
        const spanQty = container.querySelector('span:not(.customisable-tag)');

        if (spanQty) {
            let currentQty = parseInt(spanQty.innerText || '0', 10);
            let newQty = currentQty + delta;

            if (newQty <= 0) {
                // Revert to ADD button
                const formActionTarget = isMenuPage ? 'cart' : 'CartServlet';
                container.innerHTML = `
                    <form action="${formActionTarget}" method="POST" style="margin: 0; padding: 0; display: inline;">
                        <input type="hidden" name="action" value="add">
                        <input type="hidden" name="dishId" value="${dishId}">
                        <input type="hidden" name="restaurantId" value="${targetResId}">
                        <input type="hidden" name="quantity" value="1">
                        <input type="hidden" name="sourcePage" value="${currentPageName}">
                        <button type="submit" class="dish-add-btn add-btn" style="background: #fff; color: #25C578; border: 1.5px solid #25C578; padding: 4px 14px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem; box-shadow: 0 2px 6px rgba(0,0,0,0.08); cursor: pointer; text-transform: uppercase; letter-spacing: 0.5px; transition: all 0.2s;">ADD</button>
                    </form>
                `;
            } else {
                spanQty.innerText = newQty;
            }
        } else {
            // First time adding -> Convert ADD button to Stepper (- 1 +)
            if (delta > 0) {
                if (container.classList.contains('homepage-qty-container')) {
                    container.innerHTML = `
                        <div class="menu-qty-selector" style="display: inline-flex; align-items: center; justify-content: space-between; background: #fff; border: 1.5px solid #25C578; border-radius: var(--radius-sm); padding: 0 6px; height: 28px; min-width: 70px; box-shadow: 0 2px 6px rgba(0,0,0,0.08);">
                            <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="dishId" value="${dishId}">
                                <input type="hidden" name="restaurantId" value="${targetResId}">
                                <input type="hidden" name="quantity" value="-1">
                                <input type="hidden" name="sourcePage" value="${currentPageName}">
                                <button type="submit" class="menu-qty-btn" style="background: none; border: none; color: #25C578; font-size: 1rem; font-weight: 800; cursor: pointer; padding: 0 4px;">-</button>
                            </form>
                            <span class="menu-qty-value" style="font-size: 0.75rem; font-weight: 800; color: #1e293b; min-width: 12px; text-align: center;">${delta}</span>
                            <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="dishId" value="${dishId}">
                                <input type="hidden" name="restaurantId" value="${targetResId}">
                                <input type="hidden" name="quantity" value="1">
                                <input type="hidden" name="sourcePage" value="${currentPageName}">
                                <button type="submit" class="menu-qty-btn" style="background: none; border: none; color: #25C578; font-size: 1rem; font-weight: 800; cursor: pointer; padding: 0 4px;">+</button>
                            </form>
                        </div>
                    `;
                } else {
                    container.innerHTML = `
                        <div style="display: flex; align-items: center; gap: 4px; background: #25C578; color: white; padding: 2px 8px; border-radius: var(--radius-sm); font-weight: 700; font-size: 0.75rem;">
                            <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="dishId" value="${dishId}">
                                <input type="hidden" name="restaurantId" value="${targetResId}">
                                <input type="hidden" name="quantity" value="-1">
                                <input type="hidden" name="sourcePage" value="${currentPageName}">
                                <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">-</button>
                            </form>
                            <span>${delta}</span>
                            <form action="CartServlet" method="POST" style="margin: 0; padding: 0; display: inline;">
                                <input type="hidden" name="action" value="add">
                                <input type="hidden" name="dishId" value="${dishId}">
                                <input type="hidden" name="restaurantId" value="${targetResId}">
                                <input type="hidden" name="quantity" value="1">
                                <input type="hidden" name="sourcePage" value="${currentPageName}">
                                <button type="submit" style="background: none; border: none; color: white; font-weight: 800; cursor: pointer; font-size: 0.85rem; padding: 0 4px;">+</button>
                            </form>
                        </div>
                    `;
                }
            }
        }
    });
}

// Dynamically update Cart Page (cart.jsp) rows & totals instantly
function updateCartPageDomLocally(dishId, delta) {
    if (!dishId) return;

    const row = document.querySelector(`.cart-item-row[data-dish-id="${dishId}"]`);
    if (row) {
        const qtySpan = row.querySelector('.qty-value');
        const priceBlock = row.querySelector('.item-price-block');
        const unitPrice = parseFloat(row.getAttribute('data-unit-price') || '0');

        let currentQty = parseInt(qtySpan ? qtySpan.innerText : '1', 10);
        let newQty = currentQty + delta;

        if (newQty <= 0) {
            row.remove();
        } else {
            if (qtySpan) qtySpan.innerText = newQty;
            if (priceBlock) priceBlock.innerText = `₹${Math.round(unitPrice * newQty)}`;
        }
    }

    // Recalculate totals across all remaining rows
    const remainingRows = document.querySelectorAll('.cart-item-row');
    if (remainingRows.length === 0) {
        const mainContent = document.getElementById('cartMainContent');
        const emptyState = document.getElementById('emptyCartState');
        if (mainContent) mainContent.style.display = 'none';
        if (emptyState) emptyState.style.display = 'flex';
    } else {
        let subtotal = 0;
        remainingRows.forEach(r => {
            const uPrice = parseFloat(r.getAttribute('data-unit-price') || '0');
            const qSpan = r.querySelector('.qty-value');
            const q = parseInt(qSpan ? qSpan.innerText : '1', 10);
            subtotal += uPrice * q;
        });

        const deliveryFee = (subtotal > 0) ? 39 : 0;
        const gst = (subtotal > 0) ? Math.round(subtotal * 0.05) : 0;
        const grandTotal = subtotal + deliveryFee + gst;

        const billItemTotal = document.getElementById('billItemTotal');
        const billDeliveryFee = document.getElementById('billDeliveryFee');
        const billTaxes = document.getElementById('billTaxes');
        const billGrandTotal = document.getElementById('billGrandTotal');
        const btnPrices = document.querySelectorAll('.btn-price-summary');

        if (billItemTotal) billItemTotal.innerText = `₹${Math.round(subtotal)}`;
        if (billDeliveryFee) billDeliveryFee.innerText = `₹${Math.round(deliveryFee)}`;
        if (billTaxes) billTaxes.innerText = `₹${Math.round(gst)}`;
        if (billGrandTotal) billGrandTotal.innerText = `₹${Math.round(grandTotal)}`;
        btnPrices.forEach(btn => btn.innerText = `₹${Math.round(grandTotal)}`);
    }
}

// Add Button Click Ripple Animation
function initButtonRipples() {
    document.addEventListener('click', (e) => {
        const btn = e.target.closest('.dish-add-btn, .add-btn, .addon-add-btn, .nav-item, .btn-primary');
        if (!btn) return;

        const circle = document.createElement('span');
        const diameter = Math.max(btn.clientWidth, btn.clientHeight);
        const radius = diameter / 2;

        const rect = btn.getBoundingClientRect();
        circle.style.width = circle.style.height = `${diameter}px`;
        circle.style.left = `${e.clientX - rect.left - radius}px`;
        circle.style.top = `${e.clientY - rect.top - radius}px`;
        circle.classList.add('ripple');

        const existingRipple = btn.querySelector('.ripple');
        if (existingRipple) {
            existingRipple.remove();
        }

        btn.appendChild(circle);
    });
}

// Dynamically ensure Auth Modals exist in DOM for all pages (e.g., cart.jsp, menu.jsp)
function ensureAuthModalsInDOM() {
    if (!document.getElementById('signInModalOverlay')) {
        const div = document.createElement('div');
        div.className = 'modal-overlay';
        div.id = 'signInModalOverlay';
        div.style.cssText = 'position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); display: none; align-items: center; justify-content: center; z-index: 9999999; padding: 16px; overscroll-behavior: contain;';
        div.innerHTML = `
            <div class="modal-container signin-modal" style="background: rgba(255, 255, 255, 0.88); backdrop-filter: blur(30px); -webkit-backdrop-filter: blur(30px); border-radius: 28px; max-width: 440px; width: 90%; padding: 32px 28px; position: relative; box-shadow: 0 30px 60px -12px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.9), 0 0 40px rgba(255,107,53,0.15); border: 1px solid rgba(255, 255, 255, 0.8);">
                <button type="button" class="modal-close-btn" onclick="window.closeSignInModal(); return false;" style="position: absolute; top: 20px; right: 20px; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.05); border: 1px solid rgba(0, 0, 0, 0.08); font-size: 1.1rem; color: #475569; cursor: pointer; display: flex; align-items: center; justify-content: center;">✕</button>
                <div class="brand-identity" style="text-align: center; margin-bottom: 20px;">
                    <div style="width: 64px; height: 64px; background: linear-gradient(135deg, #fff0eb 0%, #ffe4d6 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 12px auto; font-size: 2.2rem; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.2); border: 2px solid #ffffff;">
                        🍽️
                    </div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0 0 4px 0; letter-spacing: -0.5px;">Welcome Back</h2>
                    <p style="font-size: 0.82rem; color: #64748b; margin: 0;">Log in to continue your food journey</p>
                </div>
                <form action="login" method="POST" id="loginForm" style="display: flex; flex-direction: column; gap: 14px;">
                    <input type="email" name="email" placeholder="Enter your email" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                    <input type="password" name="password" placeholder="Enter your password" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                    <button type="submit" style="padding: 14px; background: linear-gradient(135deg, #ff6b35 0%, #ea580c 100%); color: white; border: none; border-radius: 14px; font-weight: 800; font-size: 0.95rem; cursor: pointer; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.4);">Log In</button>
                </form>
                <div style="text-align: center; margin-top: 18px; font-size: 0.88rem; color: #64748b;">
                    Don't have an account? <a href="#signUpModalOverlay" onclick="window.openSignUpModal(); return false;" style="color: #ff6b35; font-weight: 800; text-decoration: none;">Sign Up</a>
                </div>
            </div>
        `;
        document.body.appendChild(div);
    }

    if (!document.getElementById('signUpModalOverlay')) {
        const div = document.createElement('div');
        div.className = 'modal-overlay';
        div.id = 'signUpModalOverlay';
        div.style.cssText = 'position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); display: none; align-items: center; justify-content: center; z-index: 9999999; padding: 16px; overscroll-behavior: contain;';
        div.innerHTML = `
            <div class="modal-container signup-modal" style="background: rgba(255, 255, 255, 0.88); backdrop-filter: blur(30px); -webkit-backdrop-filter: blur(30px); border-radius: 28px; max-width: 440px; width: 90%; padding: 32px 28px; position: relative; box-shadow: 0 30px 60px -12px rgba(0,0,0,0.35), inset 0 1px 0 rgba(255,255,255,0.9), 0 0 40px rgba(255,107,53,0.15); border: 1px solid rgba(255, 255, 255, 0.8);">
                <button type="button" class="modal-close-btn" onclick="window.closeSignUpModal(); return false;" style="position: absolute; top: 20px; right: 20px; width: 36px; height: 36px; border-radius: 50%; background: rgba(0, 0, 0, 0.05); border: 1px solid rgba(0, 0, 0, 0.08); font-size: 1.1rem; color: #475569; cursor: pointer; display: flex; align-items: center; justify-content: center;">✕</button>
                <div class="brand-identity" style="text-align: center; margin-bottom: 20px;">
                    <div style="width: 64px; height: 64px; background: linear-gradient(135deg, #fff0eb 0%, #ffe4d6 100%); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 12px auto; font-size: 2.2rem; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.2); border: 2px solid #ffffff;">
                        🍽️
                    </div>
                    <h2 style="font-size: 1.5rem; font-weight: 800; color: #0f172a; margin: 0 0 4px 0; letter-spacing: -0.5px;">Create Account</h2>
                    <p style="font-size: 0.82rem; color: #64748b; margin: 0;">Join Khaalo to order your favorite meals</p>
                </div>
                <form action="register" method="POST" id="signupForm" style="display: flex; flex-direction: column; gap: 14px;">
                    <input type="text" name="fullName" placeholder="Enter your full name" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                    <input type="email" name="email" placeholder="name@example.com" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                    <input type="tel" name="phone" placeholder="Enter your phone number" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                    <select name="role" style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                        <option value="customer" selected>Customer</option>
                        <option value="restaurant owner">Restaurant Owner</option>
                        <option value="delivery partner">Delivery Partner</option>
                        <option value="admin">Administrator</option>
                    </select>
                    <input type="password" name="password" placeholder="Min. 6 characters" required style="padding: 13px 16px; border-radius: 14px; border: 1.5px solid rgba(203, 213, 225, 0.8); background: rgba(248, 250, 252, 0.8); font-family: inherit; font-size: 0.9rem; color: #0f172a; outline: none;">
                    <button type="submit" style="padding: 14px; background: linear-gradient(135deg, #ff6b35 0%, #ea580c 100%); color: white; border: none; border-radius: 14px; font-weight: 800; font-size: 0.95rem; cursor: pointer; box-shadow: 0 8px 24px rgba(255, 107, 53, 0.4);">Create Account</button>
                </form>
                <div style="text-align: center; margin-top: 18px; font-size: 0.88rem; color: #64748b;">
                    Already have an account? <a href="#signInModalOverlay" onclick="window.openSignInModal(); return false;" style="color: #ff6b35; font-weight: 800; text-decoration: none;">Log In</a>
                </div>
            </div>
        `;
        document.body.appendChild(div);
    }
}

// Global Auth Modal Manager Functions (100% Reliable, Scroll Lock & Un-nested DOM)
window.openSignInModal = function() {
    window.closeSignUpModal();
    ensureAuthModalsInDOM();
    let modal = document.getElementById('signInModalOverlay');
    if (modal) {
        if (modal.parentElement !== document.body) {
            document.body.appendChild(modal);
        }
        document.body.classList.add('modal-open');
        modal.style.cssText = 'position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); display: flex; align-items: center; justify-content: center; z-index: 9999999; padding: 16px; opacity: 1; visibility: visible; pointer-events: auto; overscroll-behavior: contain;';
        modal.classList.add('active');

        // Dynamically set redirectTarget for post-login redirection to current page
        const currentPage = (window.location.pathname.split('/').pop() || 'restaurants.jsp') + window.location.search;
        let loginForm = modal.querySelector('form#loginForm, form[action*="login"]');
        if (loginForm) {
            let redirectInput = loginForm.querySelector('input[name="redirectTarget"]');
            if (!redirectInput) {
                redirectInput = document.createElement('input');
                redirectInput.type = 'hidden';
                redirectInput.name = 'redirectTarget';
                loginForm.appendChild(redirectInput);
            }
            redirectInput.value = currentPage;
        }
    }
};

window.clearAuthHash = function() {
    if (window.location.hash === '#signInModalOverlay' || window.location.hash === '#signUpModalOverlay') {
        if (window.history && window.history.replaceState) {
            let cleanUrl = window.location.pathname;
            let search = window.location.search;
            if (search) {
                search = search.replace(/[?&]error=[^&]*/g, '');
                search = search.replace(/[?&]loginRequired=[^&]*/g, '');
                if (search && search.charAt(0) !== '?') {
                    search = '?' + search;
                }
                if (search === '?') search = '';
                cleanUrl += search;
            }
            window.history.replaceState(null, null, cleanUrl);
        } else {
            window.location.hash = '';
        }
    }
};

window.closeSignInModal = function() {
    let modal = document.getElementById('signInModalOverlay');
    if (modal) {
        modal.style.display = 'none';
        modal.style.opacity = '0';
        modal.style.visibility = 'hidden';
        modal.style.pointerEvents = 'none';
        modal.classList.remove('active');
    }
    window.clearAuthHash();
    const remainingActiveModals = document.querySelectorAll('.modal-overlay.active');
    if (remainingActiveModals.length === 0) {
        document.body.classList.remove('modal-open');
        document.body.style.overflow = '';
    }
};

window.openSignUpModal = function() {
    window.closeSignInModal();
    ensureAuthModalsInDOM();
    let modal = document.getElementById('signUpModalOverlay');
    if (modal) {
        if (modal.parentElement !== document.body) {
            document.body.appendChild(modal);
        }
        document.body.classList.add('modal-open');
        modal.style.cssText = 'position: fixed; inset: 0; background: rgba(15, 23, 42, 0.75); backdrop-filter: blur(16px) saturate(180%); -webkit-backdrop-filter: blur(16px) saturate(180%); display: flex; align-items: center; justify-content: center; z-index: 9999999; padding: 16px; opacity: 1; visibility: visible; pointer-events: auto; overscroll-behavior: contain;';
        modal.classList.add('active');

        // Dynamically set redirectTarget for post-signup redirection to current page
        const currentPage = (window.location.pathname.split('/').pop() || 'restaurants.jsp') + window.location.search;
        let signupForm = modal.querySelector('form#signupForm, form[action*="register"]');
        if (signupForm) {
            let redirectInput = signupForm.querySelector('input[name="redirectTarget"]');
            if (!redirectInput) {
                redirectInput = document.createElement('input');
                redirectInput.type = 'hidden';
                redirectInput.name = 'redirectTarget';
                signupForm.appendChild(redirectInput);
            }
            redirectInput.value = currentPage;
        }
    }
};

window.closeSignUpModal = function() {
    let modal = document.getElementById('signUpModalOverlay');
    if (modal) {
        modal.style.display = 'none';
        modal.style.opacity = '0';
        modal.style.visibility = 'hidden';
        modal.style.pointerEvents = 'none';
        modal.classList.remove('active');
    }
    window.clearAuthHash();
    const remainingActiveModals = document.querySelectorAll('.modal-overlay.active');
    if (remainingActiveModals.length === 0) {
        document.body.classList.remove('modal-open');
        document.body.style.overflow = '';
    }
};

// Backdrop Click Listener & Auto-Open Trigger
document.addEventListener('DOMContentLoaded', () => {
    document.addEventListener('click', (e) => {
        if (e.target.classList.contains('modal-overlay')) {
            e.target.style.display = 'none';
            e.target.classList.remove('active');
            window.clearAuthHash();
            const remainingActiveModals = document.querySelectorAll('.modal-overlay.active');
            if (remainingActiveModals.length === 0) {
                document.body.classList.remove('modal-open');
                document.body.style.overflow = '';
            }
        }
    });

    if (window.location.search.includes('loginRequired=true') || window.location.hash.includes('signInModalOverlay')) {
        window.openSignInModal();
    } else if (window.location.hash.includes('signUpModalOverlay')) {
        window.openSignUpModal();
    }
});

// Fly-to-Cart Arc Animation (Silky Smooth 0.95s Parabolic Arc targeting floating-cart-drawer)
function animateFlyToCart(startElement) {
    if (!startElement) return;

    // 1. Locate bottom floating cart drawer or create/target bottom drawer bar
    let cartTarget = document.getElementById('floating-cart-drawer') ||
                     document.querySelector('.floating-cart-drawer, .menu-floating-cart');

    // 2. Get start coordinates
    const startRect = startElement.getBoundingClientRect();
    if (startRect.width === 0 && startRect.height === 0) return;

    const startX = startRect.left + (startRect.width / 2);
    const startY = startRect.top + (startRect.height / 2);

    // 3. Get target coordinates (bottom center floating cart bar position)
    let targetX = window.innerWidth / 2;
    let targetY = window.innerHeight - 50;

    if (cartTarget) {
        const targetRect = cartTarget.getBoundingClientRect();
        if (targetRect.width > 0 && targetRect.height > 0) {
            targetX = targetRect.left + (targetRect.width / 2);
            targetY = targetRect.top + (targetRect.height / 2);
        }
    }

    // 4. Look for dish image inside closest card or fallback to food badge
    const card = startElement.closest('.dish-card, .recommended-card, .trending-card, .menu-item-card, [data-dish-id]');
    const imgEl = card ? card.querySelector('img') : null;

    const flyer = document.createElement('div');
    flyer.className = 'fly-to-cart-element';

    const flyerSize = 44;
    const initialLeft = startX - (flyerSize / 2);
    const initialTop = startY - (flyerSize / 2);

    if (imgEl && imgEl.src && imgEl.src.length > 5 && !imgEl.src.includes('data:image/svg')) {
        flyer.style.cssText = `
            position: fixed;
            left: ${initialLeft}px;
            top: ${initialTop}px;
            width: ${flyerSize}px;
            height: ${flyerSize}px;
            border-radius: 50%;
            background-image: url('${imgEl.src}');
            background-size: cover;
            background-position: center;
            border: 2px solid #ffffff;
            box-shadow: 0 10px 30px rgba(255, 107, 53, 0.5), 0 0 15px rgba(255, 107, 53, 0.3);
            z-index: 99999999;
            pointer-events: none;
            will-change: left, top, transform, opacity;
            transition: left 0.95s cubic-bezier(0.2, 0.8, 0.25, 1), top 0.95s cubic-bezier(0.4, 0, 1, 1), transform 0.95s ease-out, opacity 0.95s ease;
        `;
    } else {
        flyer.style.cssText = `
            position: fixed;
            left: ${initialLeft}px;
            top: ${initialTop}px;
            width: ${flyerSize}px;
            height: ${flyerSize}px;
            border-radius: 50%;
            background: linear-gradient(135deg, #ff6b35 0%, #ea580c 100%);
            color: #ffffff;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.3rem;
            border: 2px solid #ffffff;
            box-shadow: 0 10px 30px rgba(255, 107, 53, 0.5), 0 0 15px rgba(255, 107, 53, 0.3);
            z-index: 99999999;
            pointer-events: none;
            will-change: left, top, transform, opacity;
            transition: left 0.95s cubic-bezier(0.2, 0.8, 0.25, 1), top 0.95s cubic-bezier(0.4, 0, 1, 1), transform 0.95s ease-out, opacity 0.95s ease;
        `;
        flyer.innerText = '🍱';
    }

    document.body.appendChild(flyer);

    // 5. Trigger smooth parabolic arc
    requestAnimationFrame(() => {
        const destLeft = targetX - (flyerSize / 2);
        const destTop = targetY - (flyerSize / 2);

        flyer.style.left = `${destLeft}px`;
        flyer.style.top = `${destTop}px`;
        flyer.style.transform = 'scale(0.25) rotate(720deg)';
        flyer.style.opacity = '0.7';
    });

    // 6. On arrival (950ms): Clean up flyer & trigger spring bounce on floating cart drawer
    setTimeout(() => {
        flyer.remove();

        const activeDrawer = document.getElementById('floating-cart-drawer') ||
                             document.querySelector('.floating-cart-drawer, .menu-floating-cart');

        if (activeDrawer) {
            activeDrawer.style.transition = 'transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1)';
            activeDrawer.style.transform = 'translate(-50%, 0) scale(1.08)';
            if (!activeDrawer.classList.contains('visible')) {
                activeDrawer.classList.add('visible');
            }
            setTimeout(() => {
                activeDrawer.style.transform = 'translate(-50%, 0) scale(1)';
                setTimeout(() => { activeDrawer.style.transition = ''; }, 250);
            }, 250);
        }
    }, 950);
}
