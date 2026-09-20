const app = !['/', '/index.html', '/de/', '/de/index.html', '/how-it-works/', '/de/so-funktionierts/'].includes(location.pathname);
const requested = new URLSearchParams(location.search).get('lang');
let language = requested;
try {
  if (['en', 'de'].includes(requested)) localStorage.setItem('language', requested);
  language ||= localStorage.getItem('language');
} catch (_) { /* Language detection also works with storage disabled. */ }
language ||= navigator.language.startsWith('de') ? 'de' : 'en';
if (app) {
  document.documentElement.dataset.view = 'app';
  document.documentElement.lang = language;
  // Carry the website choice into Flutter and preserve the scanned invite URL.
  const url = new URL(location.href);
  url.searchParams.set('lang', language);
  history.replaceState(null, '', url);
  document.getElementById('landing')?.remove();
  const script = document.createElement('script');
  script.src = '/flutter_bootstrap.js';
  document.body.append(script);
} else {
  if (language === 'de' && ['/', '/index.html'].includes(location.pathname)) location.replace('/de/' + location.search + location.hash);
  if (language === 'de' && location.pathname === '/how-it-works/') location.replace('/de/so-funktionierts/' + location.search + location.hash);
  const input = document.getElementById('invite');
  input?.addEventListener('input', () => input.setCustomValidity(''));
  document.getElementById('join-form')?.addEventListener('submit', event => {
    event.preventDefault();
    const match = input.value.trim().match(/^(?:https:\/\/songvoter\.party\/join\/)?([a-f0-9]{12})\/?(?:\?lang=(?:de|en))?$/i);
    if (match) location.assign('/join/' + match[1].toLowerCase() + '?lang=' + document.documentElement.lang);
    else {
      input.setCustomValidity(document.documentElement.lang === 'de' ? 'Gib den 12-stelligen Partycode oder einen songvoter.party-Einladungslink ein.' : 'Enter the 12-character party code or a songvoter.party invite link.');
      input.reportValidity();
    }
  });
}
