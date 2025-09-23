/**
 * =============================================================================
 * Keiko Latam - JavaScript Personalizado para Material for MkDocs
 * Funcionalidades interactivas para la documentación de la plataforma educativa
 * =============================================================================
 */

// =============================================================================
// Configuración global
// =============================================================================
window.addEventListener('DOMContentLoaded', function() {
    initializeKeiko();
});

/**
 * Inicializar funcionalidades de Keiko
 */
function initializeKeiko() {
    console.log('🎓 Inicializando Keiko Latam Documentation...');
    
    // Inicializar componentes
    initializeThemeToggle();
    initializeCodeBlocks();
    initializeAdmonitions();
    initializeCards();
    initializeTabs();
    initializeSearch();
    initializeScrollToTop();
    initializeProgressBar();
    initializeCopyButtons();
    
    console.log('✅ Keiko Latam Documentation inicializada correctamente');
}

// =============================================================================
// Toggle de tema personalizado
// =============================================================================
function initializeThemeToggle() {
    const themeToggle = document.querySelector('[data-md-component="palette"]');
    if (!themeToggle) return;
    
    // Agregar animación al toggle
    themeToggle.addEventListener('click', function() {
        document.body.style.transition = 'background-color 0.3s ease, color 0.3s ease';
        setTimeout(() => {
            document.body.style.transition = '';
        }, 300);
    });
}

// =============================================================================
// Bloques de código mejorados
// =============================================================================
function initializeCodeBlocks() {
    const codeBlocks = document.querySelectorAll('pre code');
    
    codeBlocks.forEach(block => {
        // Agregar numeración de líneas si no existe
        if (!block.querySelector('.linenumbers')) {
            addLineNumbers(block);
        }
        
        // Agregar indicador de lenguaje
        const language = block.className.match(/language-(\w+)/);
        if (language) {
            addLanguageIndicator(block, language[1]);
        }
    });
}

function addLineNumbers(block) {
    const lines = block.textContent.split('\n');
    if (lines.length > 10) { // Solo agregar números si hay más de 10 líneas
        const lineNumbers = document.createElement('div');
        lineNumbers.className = 'linenumbers';
        
        lines.forEach((_, index) => {
            const lineNumber = document.createElement('span');
            lineNumber.textContent = index + 1;
            lineNumber.className = 'line-number';
            lineNumbers.appendChild(lineNumber);
        });
        
        block.parentElement.appendChild(lineNumbers);
    }
}

function addLanguageIndicator(block, language) {
    const indicator = document.createElement('div');
    indicator.className = 'language-indicator';
    indicator.textContent = language.toUpperCase();
    block.parentElement.appendChild(indicator);
}

// =============================================================================
// Admonitions interactivos
// =============================================================================
function initializeAdmonitions() {
    const admonitions = document.querySelectorAll('.admonition');
    
    admonitions.forEach(admonition => {
        // Agregar funcionalidad de colapso
        const title = admonition.querySelector('.admonition-title');
        if (title) {
            title.style.cursor = 'pointer';
            title.addEventListener('click', function() {
                const content = admonition.querySelector('.admonition-content');
                if (content) {
                    content.style.display = content.style.display === 'none' ? 'block' : 'none';
                }
            });
        }
        
        // Agregar animación de entrada
        admonition.style.opacity = '0';
        admonition.style.transform = 'translateY(20px)';
        
        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.style.opacity = '1';
                    entry.target.style.transform = 'translateY(0)';
                    entry.target.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
                }
            });
        });
        
        observer.observe(admonition);
    });
}

// =============================================================================
// Cards interactivos
// =============================================================================
function initializeCards() {
    const cards = document.querySelectorAll('.grid.cards .card');
    
    cards.forEach((card, index) => {
        // Agregar animación de entrada escalonada
        card.style.opacity = '0';
        card.style.transform = 'translateY(30px)';
        
        setTimeout(() => {
            card.style.opacity = '1';
            card.style.transform = 'translateY(0)';
            card.style.transition = 'opacity 0.6s ease, transform 0.6s ease';
        }, index * 100);
        
        // Agregar efecto hover mejorado
        card.addEventListener('mouseenter', function() {
            this.style.transform = 'translateY(-8px) scale(1.02)';
            this.style.boxShadow = '0 20px 25px -5px rgb(0 0 0 / 0.1), 0 10px 10px -5px rgb(0 0 0 / 0.04)';
        });
        
        card.addEventListener('mouseleave', function() {
            this.style.transform = 'translateY(0) scale(1)';
            this.style.boxShadow = '0 1px 2px 0 rgb(0 0 0 / 0.05)';
        });
    });
}

// =============================================================================
// Tabs mejorados
// =============================================================================
function initializeTabs() {
    const tabs = document.querySelectorAll('.tabbed');
    
    tabs.forEach(tab => {
        const inputs = tab.querySelectorAll('input[type="radio"]');
        const labels = tab.querySelectorAll('label');
        
        inputs.forEach((input, index) => {
            input.addEventListener('change', function() {
                // Agregar animación al cambio de tab
                const content = tab.querySelector('.tabbed-content');
                if (content) {
                    content.style.opacity = '0.5';
                    setTimeout(() => {
                        content.style.opacity = '1';
                    }, 150);
                }
            });
        });
        
        // Agregar navegación con teclado
        labels.forEach((label, index) => {
            label.addEventListener('keydown', function(e) {
                if (e.key === 'ArrowLeft' && index > 0) {
                    inputs[index - 1].checked = true;
                    inputs[index - 1].focus();
                } else if (e.key === 'ArrowRight' && index < inputs.length - 1) {
                    inputs[index + 1].checked = true;
                    inputs[index + 1].focus();
                }
            });
        });
    });
}

// =============================================================================
// Búsqueda mejorada
// =============================================================================
function initializeSearch() {
    const searchInput = document.querySelector('input[type="search"]');
    if (!searchInput) return;
    
    // Agregar placeholder dinámico
    const placeholders = [
        'Buscar en la documentación...',
        '¿Cómo implementar Proof-of-Humanity?',
        '¿Configurar GitFlow?',
        '¿Desplegar en OVHCloud?',
        '¿Integrar con LRS?'
    ];
    
    let placeholderIndex = 0;
    setInterval(() => {
        searchInput.placeholder = placeholders[placeholderIndex];
        placeholderIndex = (placeholderIndex + 1) % placeholders.length;
    }, 3000);
    
    // Agregar funcionalidad de búsqueda rápida
    searchInput.addEventListener('input', debounce(function(e) {
        const query = e.target.value.toLowerCase();
        if (query.length > 2) {
            highlightSearchResults(query);
        } else {
            clearSearchHighlights();
        }
    }, 300));
}

function highlightSearchResults(query) {
    const content = document.querySelector('.md-content__inner');
    const walker = document.createTreeWalker(
        content,
        NodeFilter.SHOW_TEXT,
        null,
        false
    );
    
    let node;
    while (node = walker.nextNode()) {
        if (node.textContent.toLowerCase().includes(query)) {
            const span = document.createElement('span');
            span.className = 'search-highlight';
            span.textContent = node.textContent;
            node.parentNode.replaceChild(span, node);
        }
    }
}

function clearSearchHighlights() {
    const highlights = document.querySelectorAll('.search-highlight');
    highlights.forEach(highlight => {
        highlight.parentNode.replaceChild(
            document.createTextNode(highlight.textContent),
            highlight
        );
    });
}

// =============================================================================
// Botón de scroll to top
// =============================================================================
function initializeScrollToTop() {
    const scrollButton = document.createElement('button');
    scrollButton.className = 'scroll-to-top';
    scrollButton.innerHTML = '↑';
    scrollButton.title = 'Volver arriba';
    document.body.appendChild(scrollButton);
    
    // Mostrar/ocultar botón según scroll
    window.addEventListener('scroll', throttle(function() {
        if (window.pageYOffset > 300) {
            scrollButton.style.display = 'block';
        } else {
            scrollButton.style.display = 'none';
        }
    }, 100));
    
    // Funcionalidad del botón
    scrollButton.addEventListener('click', function() {
        window.scrollTo({
            top: 0,
            behavior: 'smooth'
        });
    });
}

// =============================================================================
// Barra de progreso de lectura
// =============================================================================
function initializeProgressBar() {
    const progressBar = document.createElement('div');
    progressBar.className = 'reading-progress';
    document.body.appendChild(progressBar);
    
    window.addEventListener('scroll', throttle(function() {
        const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
        const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
        const scrolled = (winScroll / height) * 100;
        
        progressBar.style.width = scrolled + '%';
    }, 10));
}

// =============================================================================
// Botones de copia mejorados
// =============================================================================
function initializeCopyButtons() {
    const copyButtons = document.querySelectorAll('.copy');
    
    copyButtons.forEach(button => {
        button.addEventListener('click', function() {
            const codeBlock = this.closest('.highlight').querySelector('code');
            const text = codeBlock.textContent;
            
            navigator.clipboard.writeText(text).then(() => {
                // Feedback visual
                const originalText = this.textContent;
                this.textContent = '✓ Copiado!';
                this.style.background = '#10b981';
                
                setTimeout(() => {
                    this.textContent = originalText;
                    this.style.background = '';
                }, 2000);
            }).catch(err => {
                console.error('Error al copiar: ', err);
                this.textContent = '❌ Error';
                this.style.background = '#ef4444';
            });
        });
    });
}

// =============================================================================
// Utilidades
// =============================================================================

/**
 * Debounce function
 */
function debounce(func, wait) {
    let timeout;
    return function executedFunction(...args) {
        const later = () => {
            clearTimeout(timeout);
            func(...args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}

/**
 * Throttle function
 */
function throttle(func, limit) {
    let inThrottle;
    return function() {
        const args = arguments;
        const context = this;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(() => inThrottle = false, limit);
        }
    };
}

// =============================================================================
// Estilos CSS dinámicos
// =============================================================================
const dynamicStyles = `
<style>
/* Botón scroll to top */
.scroll-to-top {
    position: fixed;
    bottom: 2rem;
    right: 2rem;
    width: 3rem;
    height: 3rem;
    background: var(--keiko-primary);
    color: white;
    border: none;
    border-radius: 50%;
    font-size: 1.5rem;
    cursor: pointer;
    display: none;
    z-index: 1000;
    box-shadow: 0 4px 6px -1px rgb(0 0 0 / 0.1);
    transition: all 0.3s ease;
}

.scroll-to-top:hover {
    background: var(--keiko-primary-dark);
    transform: scale(1.1);
}

/* Barra de progreso de lectura */
.reading-progress {
    position: fixed;
    top: 0;
    left: 0;
    width: 0%;
    height: 3px;
    background: linear-gradient(90deg, var(--keiko-primary), var(--keiko-secondary));
    z-index: 1000;
    transition: width 0.1s ease;
}

/* Indicador de lenguaje */
.language-indicator {
    position: absolute;
    top: 0.5rem;
    right: 0.5rem;
    background: var(--keiko-primary);
    color: white;
    padding: 0.25rem 0.5rem;
    border-radius: 0.25rem;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
}

/* Números de línea */
.linenumbers {
    position: absolute;
    left: 0;
    top: 0;
    background: #f8fafc;
    border-right: 1px solid #e5e7eb;
    padding: 1rem 0.5rem;
    font-family: var(--keiko-font-mono);
    font-size: 0.875rem;
    color: #6b7280;
    user-select: none;
}

.line-number {
    display: block;
    line-height: 1.6;
}

/* Resaltado de búsqueda */
.search-highlight {
    background: #fef3c7;
    padding: 0.125rem 0.25rem;
    border-radius: 0.25rem;
    font-weight: 600;
}

/* Animaciones de entrada */
@keyframes slideInUp {
    from {
        opacity: 0;
        transform: translateY(30px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.card, .admonition {
    animation: slideInUp 0.6s ease-out;
}

/* Responsive */
@media (max-width: 768px) {
    .scroll-to-top {
        bottom: 1rem;
        right: 1rem;
        width: 2.5rem;
        height: 2.5rem;
        font-size: 1.25rem;
    }
    
    .language-indicator {
        font-size: 0.625rem;
        padding: 0.125rem 0.25rem;
    }
}
</style>
`;

document.head.insertAdjacentHTML('beforeend', dynamicStyles);

// =============================================================================
// Event listeners globales
// =============================================================================

// Mostrar notificación de carga
window.addEventListener('load', function() {
    console.log('🎓 Keiko Latam Documentation cargada completamente');
    
    // Agregar clase de carga completa
    document.body.classList.add('loaded');
});

// Manejar errores de JavaScript
window.addEventListener('error', function(e) {
    console.error('Error en Keiko Documentation:', e.error);
});

// =============================================================================
// Exportar funciones para uso externo
// =============================================================================
window.KeikoDocs = {
    initializeKeiko,
    highlightSearchResults,
    clearSearchHighlights,
    debounce,
    throttle
};
