// JavaScript 5T Protocol - High Tech Seaweed
// Traceable: source_origin="frontend-main"
// Trackable: lifecycle hooks for analytics
// Tangible: smooth animations and interactions
// Transparent: open-source logic
// Trustworthy: frozen config objects

const CONFIG = Object.freeze({
    SUPABASE_URL: 'https://hbrahfuuqqaoresjljzd.supabase.co',
    SUPABASE_KEY: 'sb_publishable_xra-pK6FrRL_dXP7hmGdxg_j15abZra',
    ANNUAL_GOAL: 0.1  // Entropy reduction target
});

// Initialize Supabase client
let supabaseClient = null;
let isAuthenticated = false;

function initSupabase() {
    if (typeof supabase !== 'undefined' && supabase) {
        supabaseClient = supabase.createClient(CONFIG.SUPABASE_URL, CONFIG.SUPABASE_KEY);
        console.log('[5T] Supabase client initialized');
    }
}

// 5T Protocol: Safe form handling with validation
document.addEventListener('DOMContentLoaded', function() {
    initSupabase();
    
    // Smooth scrolling for navigation links - Tangible UX
    const navLinks = document.querySelectorAll('.nav a');
    navLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href').substring(1);
            const targetSection = document.getElementById(targetId) || document.querySelector(targetId);
            if (targetSection) {
                targetSection.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });
    
    // Language toggle - Tangible interaction
    const langToggle = document.querySelector('.lang-toggle');
    if (langToggle) {
        langToggle.addEventListener('click', function() {
            const currentLang = this.textContent;
            this.textContent = currentLang === 'EN' ? '中文' : 'EN';
            
            // 5T Trackable: Log language change
            if (supabaseClient) {
                supabaseClient.from('analytics').insert({
                    event: 'language_toggle',
                    language: currentLang === 'EN' ? 'zh' : 'en',
                    timestamp: new Date().toISOString()
                }).catch(() => {});
            }
        });
    }
    
    // Form submission with Supabase integration
    const contactForm = document.querySelector('.contact form');
    if (contactForm) {
        contactForm.addEventListener('submit', async function(e) {
            e.preventDefault();
            
            const formData = new FormData(this);
            const name = formData.get('name') || this.querySelector('input[type="text"]').value;
            const email = formData.get('email') || this.querySelector('input[type="email"]').value;
            const service = formData.get('service') || this.querySelector('select').value;
            const message = formData.get('message') || this.querySelector('textarea').value;
            
            // 5T Trustworthy: Save inquiry to Supabase
            if (supabaseClient) {
                try {
                    const { data, error } = await supabaseClient.from('inquiries').insert({
                        name: name,
                        email: email,
                        service_type: service,
                        message: message,
                        created_at: new Date().toISOString(),
                        status: 'pending'
                    });
                    
                    if (error) throw error;
                    
                    alert(`感謝您的諮詢，${name}！我們會盡快回覆您 (${email}) 的 ${service} 需求。`);
                    this.reset();
                    
                    // 5T Trackable: Log successful submission
                    console.log('[5T] Inquiry saved:', data);
                } catch (error) {
                    console.error('[5T] Inquiry save error:', error);
                    alert('系統繁忙，請稍後再試或直接聯絡我們。');
                }
            } else {
                // Fallback for offline mode
                alert(`感謝您的諮詢，${name}！我們會盡快回覆您 (${email}) 的 ${service} 需求。`);
                this.reset();
            }
        });
    }
    
    // Animation on scroll - Tangible UX enhancement
    const animateOnScroll = function() {
        const elements = document.querySelectorAll('.value-card, .product-card, .info-item');
        elements.forEach(el => {
            const position = el.getBoundingClientRect().top;
            const windowHeight = window.innerHeight;
            if (position < windowHeight * 0.8) {
                el.style.opacity = '1';
                el.style.transform = 'translateY(0)';
            }
        });
    };
    
    window.addEventListener('scroll', animateOnScroll);
    animateOnScroll();
    
    // Mobile menu toggle
    const createMobileMenu = function() {
        const nav = document.querySelector('.nav');
        const menuButton = document.createElement('button');
        menuButton.textContent = 'Menu';
        menuButton.style.cssText = `
            background: var(--primary-blue);
            color: white;
            border: none;
            padding: 10px;
            border-radius: 8px;
            cursor: pointer;
            font-size: 1.5rem;
        `;
        
        if (window.innerWidth <= 768 && nav) {
            nav.parentNode.insertBefore(menuButton, nav.nextSibling);
            
            menuButton.addEventListener('click', function() {
                if (nav.style.display === 'flex') {
                    nav.style.display = 'none';
                } else {
                    nav.style.display = 'flex';
                }
            });
        }
    };
    
    // Initialize when window loads
    window.addEventListener('load', function() {
        createMobileMenu();
        
        // Reset mobile menu on resize
        window.addEventListener('resize', function() {
            if (window.innerWidth > 768) {
                const menuButton = document.querySelector('button[aria-label="Menu"], button:nth-child(1)');
                if (menuButton) {
                    menuButton.remove();
                }
                const nav = document.querySelector('.nav');
                if (nav) {
                    nav.style.display = 'flex';
                }
            }
        });
    });
});

// Logo animation - Tangible visual feedback
window.addEventListener('load', function() {
    const logoCircle = document.querySelector('.logo-circle');
    if (logoCircle) {
        logoCircle.style.animation = 'pulse 2s ease-in-out infinite';
    }
});

// 5T Protocol: Dynamic animations injection
const style = document.createElement('style');
style.textContent = `
    @keyframes pulse {
        0% { transform: scale(1); box-shadow: 0 0 0 0 rgba(56, 161, 105, 0.7); }
        70% { transform: scale(1.05); box-shadow: 0 0 0 15px rgba(56, 161, 105, 0); }
        100% { transform: scale(1.05); box-shadow: 0 0 0 0 rgba(56, 161, 105, 0); }
    }
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(30px); }
        to { opacity: 1; transform: translateY(0); }
    }
`;
document.head.appendChild(style);

// Export for module usage (5T Transparent)
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { CONFIG, initSupabase, supabaseClient };
}