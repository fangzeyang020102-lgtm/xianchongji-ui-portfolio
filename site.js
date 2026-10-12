(() => {
 const progress = document.getElementById('progress');
 const backTop = document.getElementById('backTop');
 const chapters = [...document.querySelectorAll('.project-chapter')];
 const links = [...document.querySelectorAll('.chapter-link')];
 let ticking = false;
 const updateProgress = () => {
   const scrollable = document.documentElement.scrollHeight - window.innerHeight;
   const pct = scrollable > 0 ? Math.max(0, Math.min(100, window.scrollY / scrollable * 100)) : 0;
   progress.style.width = pct + '%';
   backTop.classList.toggle('visible', window.scrollY > 900);
   ticking = false;
 };
 window.addEventListener('scroll', () => { if (!ticking) { window.requestAnimationFrame(updateProgress); ticking = true; } }, {passive:true});
 backTop.addEventListener('click', () => window.scrollTo({top:0, behavior:window.matchMedia('(prefers-reduced-motion: reduce)').matches?'auto':'smooth'}));
 updateProgress();
 if ('IntersectionObserver' in window) {
   const ob = new IntersectionObserver(entries => {
     const visible = entries.filter(e => e.isIntersecting).sort((a,b)=>a.boundingClientRect.top-b.boundingClientRect.top);
     if (!visible.length) return;
     const id=visible[0].target.id;
     links.forEach(link => link.setAttribute('aria-current', String(link.dataset.chapter === id)));
     const chosen=links.find(link=>link.dataset.chapter===id);
     if(chosen && window.innerWidth<780) chosen.scrollIntoView({block:'nearest', inline:'nearest'});
   }, {rootMargin:'-8% 0px -68% 0px'});
   chapters.forEach(s=>ob.observe(s));
 }
})();
