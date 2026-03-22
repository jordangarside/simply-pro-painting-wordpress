document.addEventListener('DOMContentLoaded', () => {
  document.documentElement.classList.add('js-enabled');

  const elements = document.querySelectorAll('.animate-in');

  if ('IntersectionObserver' in window) {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add('visible');
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.05, rootMargin: '0px 0px 80px 0px' }
    );

    elements.forEach((el) => observer.observe(el));
  } else {
    elements.forEach((el) => el.classList.add('visible'));
  }
});
