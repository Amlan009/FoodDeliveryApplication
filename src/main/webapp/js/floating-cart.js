/**
 * Khaalo Floating Bottom Cart Drawer (Swiggy / Zomato style)
 */

document.addEventListener('DOMContentLoaded', () => {
    createFloatingCartDrawer();
    window.updateFloatingCartState();
});

function createFloatingCartDrawer() {
    if (document.getElementById('floating-cart-drawer')) return;

    const drawer = document.createElement('div');
    drawer.id = 'floating-cart-drawer';
    drawer.className = 'floating-cart-drawer';
    drawer.innerHTML = `
        <div class="floating-cart-info">
            <span class="floating-cart-count" id="floatingCartCount">0 ITEMS</span>
            <span class="floating-cart-price" id="floatingCartPrice">₹0</span>
        </div>
        <a href="cart" class="floating-cart-btn" id="floatingCartBtn">
            <span>View Cart</span>
            <span>🛒 →</span>
        </a>
    `;
    document.body.appendChild(drawer);
}

window.updateFloatingCartState = function() {
    let totalItems = 0;
    let totalPrice = 0;

    if (window.cartItems && Array.isArray(window.cartItems)) {
        window.cartItems.forEach(item => {
            totalItems += item.quantity;
            totalPrice += item.price * item.quantity;
        });
    }

    const drawer = document.getElementById('floating-cart-drawer');
    const countElem = document.getElementById('floatingCartCount');
    const priceElem = document.getElementById('floatingCartPrice');

    if (totalItems > 0) {
        if (countElem) countElem.innerText = `${totalItems} ITEM${totalItems > 1 ? 'S' : ''} ADDED`;
        if (priceElem) priceElem.innerText = `₹${Math.round(totalPrice)}`;
        if (drawer) drawer.classList.add('visible');
    } else {
        if (drawer) drawer.classList.remove('visible');
    }
};

