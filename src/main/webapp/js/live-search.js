/**
 * Khaalo Live Search & Diet Filter Engine
 */

document.addEventListener('DOMContentLoaded', () => {
    initLiveSearch();
    initLiveDietFilter();
});

function initLiveSearch() {
    const searchInputs = document.querySelectorAll('#searchInput, #menuSearchInput, .search-input, .menu-search-input, input[placeholder*="Search" i], input[placeholder*="search" i]');
    
    searchInputs.forEach(input => {
        const handleSearch = (e) => {
            const query = e.target.value.trim().toLowerCase();
            filterPageContent(query);
        };
        input.addEventListener('input', handleSearch);
        input.addEventListener('keyup', handleSearch);
    });
}

function filterPageContent(query) {
    // 1. Filter Popular Restaurant Cards on Homepage
    const restaurantCards = document.querySelectorAll('.top-restaurant-card, .restaurant-card');
    restaurantCards.forEach(card => {
        const text = card.innerText.toLowerCase();
        if (query === '' || text.includes(query)) {
            card.style.display = '';
        } else {
            card.style.display = 'none';
        }
    });

    // 2. Filter Recommended & Trending Cards on Homepage
    const homepageFoodCards = document.querySelectorAll('.recommended-card, .trending-card');
    homepageFoodCards.forEach(card => {
        const text = card.innerText.toLowerCase();
        if (query === '' || text.includes(query)) {
            card.style.display = '';
        } else {
            card.style.display = 'none';
        }
    });

    // 3. Filter Dish Cards on Menu Page
    const dishCards = document.querySelectorAll('.menu-card, .dish-card');
    dishCards.forEach(card => {
        const text = card.innerText.toLowerCase();
        if (query === '' || text.includes(query)) {
            card.style.display = '';
        } else {
            card.style.display = 'none';
        }
    });

    // 4. Hide empty Category Sections on Menu Page if no matching dishes remain
    const categoryBlocks = document.querySelectorAll('.category-block');
    categoryBlocks.forEach(block => {
        const visibleDishes = block.querySelectorAll('.menu-card:not([style*="display: none"]), .dish-card:not([style*="display: none"])');
        if (query !== '' && visibleDishes.length === 0) {
            block.style.display = 'none';
        } else {
            block.style.display = '';
        }
    });
}

function initLiveDietFilter() {
    const vegBtns = document.querySelectorAll('.veg-btn, .veg-toggle, a[href*="diet=veg"]');
    const nonVegBtns = document.querySelectorAll('.non-veg-btn, .nonveg-toggle, a[href*="diet=non-veg"]');

    vegBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            if (!e.ctrlKey && !e.metaKey) {
                e.preventDefault();
                toggleDietFilter('veg', btn);
            }
        });
    });

    nonVegBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
            if (!e.ctrlKey && !e.metaKey) {
                e.preventDefault();
                toggleDietFilter('non-veg', btn);
            }
        });
    });
}

function toggleDietFilter(dietType, activeBtn) {
    const allDietBtns = document.querySelectorAll('.veg-toggle-btn, .diet-toggle, .veg-btn, .non-veg-btn');
    const isAlreadyActive = activeBtn.classList.contains('active');

    allDietBtns.forEach(btn => btn.classList.remove('active'));

    let targetDiet = dietType;
    if (!isAlreadyActive) {
        activeBtn.classList.add('active');
    } else {
        targetDiet = 'all';
    }

    const foodCards = document.querySelectorAll('.recommended-card, .trending-card, .menu-card, .dish-card');
    foodCards.forEach(card => {
        const cardDiet = card.getAttribute('data-diet');
        if (!cardDiet) return;

        if (targetDiet === 'veg' && cardDiet !== 'veg') {
            card.style.display = 'none';
        } else if (targetDiet === 'non-veg' && cardDiet === 'veg') {
            card.style.display = 'none';
        } else {
            card.style.display = '';
        }
    });

    // Hide empty category sections on menu page
    const categoryBlocks = document.querySelectorAll('.category-block');
    categoryBlocks.forEach(block => {
        const visibleDishes = block.querySelectorAll('.menu-card:not([style*="display: none"]), .dish-card:not([style*="display: none"])');
        if (targetDiet !== 'all' && visibleDishes.length === 0) {
            block.style.display = 'none';
        } else {
            block.style.display = '';
        }
    });
}
