function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString();
}

document.addEventListener('DOMContentLoaded', () => {
  console.log('Page loaded:', window.location.pathname);
});