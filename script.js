  /* -- FAQ toggle -- */
  function toggleFaq(btn) {
    btn.parentElement.classList.toggle('open');
  }

  /* -- Particle canvas (ultra-light: 30fps cap, 60 particles max, Float32Array packed, pauses off-tab) -- */
  (function(){
    var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    var canvas = document.getElementById('particle-canvas');
    if (!canvas || reduceMotion) { if (canvas) canvas.style.display = 'none'; return; }

    var ctx = canvas.getContext('2d', { alpha: true, desynchronized: true, willReadFrequently: false });
    var DPR = Math.min(window.devicePixelRatio || 1, 1.5);
    var W = 0, H = 0;

    function resize() {
      W = window.innerWidth;
      H = window.innerHeight;
      canvas.width  = Math.floor(W * DPR);
      canvas.height = Math.floor(H * DPR);
      canvas.style.width  = W + 'px';
      canvas.style.height = H + 'px';
      ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
    }
    resize();

    var resizeT;
    window.addEventListener('resize', function() {
      clearTimeout(resizeT);
      resizeT = setTimeout(resize, 250);
    }, { passive: true });

    var N = Math.max(30, Math.min(60, Math.round((W * H) / 18000)));
    var pts = new Float32Array(N * 5);
    for (var i = 0; i < N; i++) {
      var b = i * 5;
      pts[b]   = Math.random() * W;
      pts[b+1] = Math.random() * H;
      pts[b+2] = Math.random() * 1.0 + 0.2;
      pts[b+3] = Math.random() * 0.3 + 0.06;
      pts[b+4] = Math.random() * 0.5 + 0.15;
    }

    var running = true;
    var rafId = 0;
    var lastTime = 0;
    var FRAME_INTERVAL = 1000 / 30;

    function draw(now) {
      if (!running) return;
      rafId = requestAnimationFrame(draw);
      var delta = now - lastTime;
      if (delta < FRAME_INTERVAL) return;
      lastTime = now - (delta % FRAME_INTERVAL);

      ctx.clearRect(0, 0, W, H);
      ctx.beginPath();
      ctx.fillStyle = 'rgba(168,85,247,1)';

      for (var i = 0; i < N; i++) {
        var b = i * 5;
        ctx.globalAlpha = pts[b+4];
        ctx.moveTo(pts[b] + pts[b+2], pts[b+1]);
        ctx.arc(pts[b], pts[b+1], pts[b+2], 0, 6.2831853);
        pts[b+1] -= pts[b+3];
        if (pts[b+1] < -4) { pts[b+1] = H + 4; pts[b] = Math.random() * W; }
      }
      ctx.fill();
      ctx.globalAlpha = 1;
    }
    rafId = requestAnimationFrame(draw);

    document.addEventListener('visibilitychange', function() {
      if (document.hidden) {
        running = false;
        cancelAnimationFrame(rafId);
      } else if (!running) {
        running = true;
        lastTime = 0;
        rafId = requestAnimationFrame(draw);
      }
    });
  })();

  /* -- Scroll reveal -- */
  (function(){
    var reveals = document.querySelectorAll('.reveal');
    if (!reveals.length) return;
    var io = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (e.isIntersecting) {
          var delay = parseFloat(e.target.style.transitionDelay || 0) * 1000;
          if (delay > 0) {
            setTimeout(function() { e.target.classList.add('visible'); }, delay);
          } else {
            e.target.classList.add('visible');
          }
          io.unobserve(e.target);
        }
      });
    }, { threshold: 0.08, rootMargin: '0px 0px -40px 0px' });
    reveals.forEach(function(el) { io.observe(el); });
  })();

  /* -- Animated counters -- */
  (function(){
    var counters = document.querySelectorAll('.stat-num[data-target]');
    if (!counters.length) return;
    function animateCounter(el) {
      var target = parseFloat(el.dataset.target);
      var suffix = el.dataset.suffix || '';
      var duration = 1500;
      var start = performance.now();
      function step(now) {
        var p = Math.min((now - start) / duration, 1);
        var eased = 1 - Math.pow(1 - p, 3);
        el.textContent = Math.round(target * eased) + suffix;
        if (p < 1) requestAnimationFrame(step);
      }
      requestAnimationFrame(step);
    }
    var counterIO = new IntersectionObserver(function(entries) {
      entries.forEach(function(e) {
        if (e.isIntersecting) { animateCounter(e.target); counterIO.unobserve(e.target); }
      });
    }, { threshold: 0.3 });
    counters.forEach(function(el) { counterIO.observe(el); });
  })();

  /* -- Theme toggle -- */
  (function(){
    var btn = document.getElementById('themeToggle');
    if (!btn) return;
    var root = document.documentElement;
    btn.addEventListener('click', function(ev){
      ev.preventDefault();
      var isLight = root.getAttribute('data-theme') === 'light';
      if (isLight) {
        root.removeAttribute('data-theme');
        try { localStorage.setItem('theme','dark'); } catch(e) {}
      } else {
        root.setAttribute('data-theme','light');
        try { localStorage.setItem('theme','light'); } catch(e) {}
      }
    });
  })();

  /* -- Filter (batch DOM writes in rAF to prevent layout thrashing) -- */
  (function(){
    var filterBtns = document.querySelectorAll('.filter-btn');
    var allCards   = document.querySelectorAll('.card');
    
    var urlParams = new URLSearchParams(window.location.search);
    var sellerFilter = urlParams.get('seller');

    // Hide cards that don't match the seller parameter initially
    if (sellerFilter && allCards.length) {
      allCards.forEach(function(card) {
        if (card.dataset.seller !== sellerFilter) {
          card.classList.add('hidden');
        }
      });
    }

    if (!filterBtns.length) return;

    filterBtns.forEach(function(btn) {
      btn.addEventListener('click', function() {
        filterBtns.forEach(function(b) { b.classList.remove('active'); });
        btn.classList.add('active');
        var f = btn.dataset.filter;

        requestAnimationFrame(function() {
          allCards.forEach(function(card) {
            var status     = card.dataset.status;
            var region     = card.dataset.region;
            var priceRange = card.dataset.price;
            var seller     = card.dataset.seller;
            var show = false;

            if (f === 'all')            show = true;
            else if (f === 'available') show = status === 'available';
            else if (f === 'ind')       show = region === 'ind';
            else if (f === 'php')       show = region === 'php';
            else if (f === 'under6k')   show = (priceRange === 'under3k' || priceRange === 'under6k') && status === 'available';
            else if (f === 'under10k')  show = (priceRange === 'under3k' || priceRange === 'under6k' || priceRange === 'under10k') && status === 'available';
            else if (f === 'above10k')  show = priceRange === 'above10k' && status === 'available';

            // Respect URL seller param
            if (sellerFilter && seller !== sellerFilter) {
              show = false;
            }

            card.classList.toggle('hidden', !show);
          });
        });
      });
    });
  })();
