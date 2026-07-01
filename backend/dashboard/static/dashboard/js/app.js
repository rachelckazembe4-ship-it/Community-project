document.addEventListener('DOMContentLoaded', function() {
    const lang = new URLSearchParams(window.location.search).get('lang') || 'sw';
    
    document.querySelectorAll('[data-sw][data-en]').forEach(el => {
        const swText = el.getAttribute('data-sw');
        const enText = el.getAttribute('data-en');
        if (swText && enText) {
            el.textContent = lang === 'sw' ? swText : enText;
        }
    });
    
    document.querySelectorAll('[data-sw-placeholder][data-en-placeholder]').forEach(el => {
        const swPh = el.getAttribute('data-sw-placeholder');
        const enPh = el.getAttribute('data-en-placeholder');
        if (swPh && enPh) {
            el.placeholder = lang === 'sw' ? swPh : enPh;
        }
    });
    
    const navItems = document.querySelectorAll('.nav-item');
    navItems.forEach(item => {
        item.addEventListener('click', function(e) {
            navItems.forEach(nav => nav.classList.remove('active'));
            this.classList.add('active');
        });
    });
    
    const currentPath = window.location.pathname;
    navItems.forEach(item => {
        if (item.getAttribute('href') && currentPath.startsWith(item.getAttribute('href'))) {
            navItems.forEach(nav => nav.classList.remove('active'));
            item.classList.add('active');
        }
    });
    
    fetch('/api/analytics/summary/')
        .then(r => r.json())
        .then(data => {
            if (data.total_reports !== undefined) {
                document.getElementById('total-reports').textContent = data.total_reports.toLocaleString();
                document.getElementById('female-reports').textContent = data.female_percentage + '%';
                document.getElementById('male-reports').textContent = data.male_percentage + '%';
            }
        })
        .catch(() => {});
    
    fetch('/api/reports/weekly/')
        .then(r => r.json())
        .then(data => {
            if (data.insights && data.insights.length > 0) {
                const insightsGrid = document.querySelector('.insights-grid');
                if (insightsGrid) {
                    insightsGrid.innerHTML = data.insights.map(insight => {
                        return `<div class="insight-card border-${insight.color}">
                            <p class="insight-text">${insight.text_sw}</p>
                        </div>`;
                    }).join('');
                }
            }
        })
        .catch(() => {});
});
