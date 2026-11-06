/* Star Bazaar UI — tiny helper: line icons and a seeded starfield. No React. */
(function () {
  var P = {
    energy: '<path d="M12 2.5l5.5 7L12 21.5 6.5 9.5z"/><path d="M6.5 9.5h11M12 2.5l-2 7 2 12 2-12z"/>',
    food: '<path d="M12 21.5V8.5"/><path d="M12 8.5c0-3 2-5.3 4.8-5.8 0 3-2 5.3-4.8 5.8zM12 8.5C12 5.5 10 3.2 7.2 2.7c0 3 2 5.3 4.8 5.8z"/><path d="M12 14.5c0-2.6 1.9-4.6 4.5-5 0 2.6-1.9 4.6-4.5 5zM12 14.5c0-2.6-1.9-4.6-4.5-5 0 2.6 1.9 4.6 4.5 5z"/>',
    cash: '<circle cx="12" cy="12" r="8.5"/><path d="M14.6 9.3c-.5-.9-1.4-1.4-2.6-1.4-1.5 0-2.6.8-2.6 2s1.1 1.7 2.6 2.1c1.5.4 2.6.9 2.6 2.1s-1.1 2.1-2.6 2.1c-1.2 0-2.1-.5-2.6-1.4M12 6.2v1.7M12 16.2v1.6"/>',
    expenses: '<path d="M4 6h16M4 12h10M4 18h6"/><path d="M17 14v6M14.5 17.5L17 20l2.5-2.5"/>',
    skills: '<circle cx="12" cy="4.5" r="2"/><circle cx="5.5" cy="19.5" r="2"/><circle cx="12" cy="19.5" r="2"/><circle cx="18.5" cy="19.5" r="2"/><path d="M12 6.5v11M12 11l-6.5 6.5M12 11l6.5 6.5"/>',
    ship: '<path d="M3.5 9h11l6 3-6 3h-11z"/><path d="M7 9v6M10.5 9v6M3.5 12H1.5"/>',
    route: '<circle cx="5" cy="17.5" r="2"/><circle cx="19" cy="6.5" r="2"/><path d="M7 17.5c6 0 4-11 10-11"/>',
    storage: '<path d="M3.5 7.5L12 3l8.5 4.5v9L12 21l-8.5-4.5z"/><path d="M3.5 7.5L12 12l8.5-4.5M12 12v9"/>',
    planet: '<circle cx="12" cy="12" r="5.5"/><ellipse cx="12" cy="12" rx="10.5" ry="3.4" transform="rotate(-20 12 12)"/>',
    research: '<path d="M9.5 3h5M10.5 3v6L5 19.2A1.3 1.3 0 0 0 6.2 21h11.6a1.3 1.3 0 0 0 1.2-1.8L13.5 9V3"/><path d="M7.4 15h9.2"/>',
    expansion: '<path d="M12 3v18M3 12h18"/><path d="M9.5 5.5L12 3l2.5 2.5M9.5 18.5L12 21l2.5-2.5M5.5 9.5L3 12l2.5 2.5M18.5 9.5L21 12l-2.5 2.5"/>',
    notice: '<path d="M6 16v-5a6 6 0 0 1 12 0v5l1.5 2h-15z"/><path d="M10 20.5a2 2 0 0 0 4 0"/>',
    event: '<path d="M12 3l2.2 6.3L21 12l-6.8 2.7L12 21l-2.2-6.3L3 12l6.8-2.7z"/>',
    lock: '<rect x="5" y="11" width="14" height="10" rx="2"/><path d="M8 11V8a4 4 0 0 1 8 0v3"/>',
    pause: '<path d="M9 5v14M15 5v14"/>',
    play: '<path d="M8 5l11 7-11 7z"/>',
    chevron: '<path d="M9 5l7 7-7 7"/>',
    back: '<path d="M15 5l-7 7 7 7"/>',
    close: '<path d="M6 6l12 12M18 6L6 18"/>',
    plus: '<path d="M12 6v12M6 12h12"/>',
    mark: '<circle cx="12" cy="12" r="9.5"/><path d="M12 4.5l2.6 7.5L12 19.5 9.4 12z"/>'
  };
  function icon(name) { return '<svg viewBox="0 0 24 24" aria-hidden="true">' + (P[name] || '') + '</svg>'; }
  function rng(seed) { var s = seed >>> 0 || 1; return function () { s ^= s << 13; s ^= s >>> 17; s ^= s << 5; return ((s >>> 0) % 100000) / 100000; }; }
  function starfield(canvas, opts) {
    opts = opts || {};
    var r = rng(opts.seed || 7), dpr = window.devicePixelRatio || 1;
    var w = canvas.clientWidth || canvas.width, h = canvas.clientHeight || canvas.height;
    canvas.width = w * dpr; canvas.height = h * dpr;
    var c = canvas.getContext('2d'); c.scale(dpr, dpr);
    var n = Math.round(w * h * (opts.density || 0.0011));
    var tints = ['255,246,230', '241,212,160', '200,220,255', '255,255,255'];
    for (var i = 0; i < n; i++) {
      var x = r() * w, y = r() * h, t = r(), rad = t > 0.985 ? 1.5 : t > 0.9 ? 1 : 0.55;
      var a = 0.25 + r() * 0.65, col = tints[Math.floor(r() * tints.length)];
      if (rad > 1.2) { var g = c.createRadialGradient(x, y, 0, x, y, rad * 5); g.addColorStop(0, 'rgba(' + col + ',' + a * 0.6 + ')'); g.addColorStop(1, 'rgba(' + col + ',0)'); c.fillStyle = g; c.beginPath(); c.arc(x, y, rad * 5, 0, 6.283); c.fill(); }
      c.fillStyle = 'rgba(' + col + ',' + a + ')'; c.beginPath(); c.arc(x, y, rad, 0, 6.283); c.fill();
    }
  }
  function hydrate(root) {
    root = root || document;
    var els = root.querySelectorAll('[data-icon]');
    for (var i = 0; i < els.length; i++) { els[i].classList.add('ds-icon'); els[i].innerHTML = icon(els[i].getAttribute('data-icon')); }
    var cs = root.querySelectorAll('canvas.ds-stars');
    for (var j = 0; j < cs.length; j++) starfield(cs[j], { seed: +cs[j].getAttribute('data-seed') || 7, density: +cs[j].getAttribute('data-density') || undefined });
  }
  /* Numbers the way the game writes them: 6,840 · +348 · −80 */
  function num(n, signed) { var s = Math.abs(n).toLocaleString('en-US'); return n < 0 ? '−' + s : (signed ? '+' + s : s); }
  window.StarBazaar = { icon: icon, icons: Object.keys(P), starfield: starfield, hydrate: hydrate, num: num };
})();
