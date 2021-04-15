function ecrire(event, name) {
  var n = document.getElementById('mail'),
      m = document.getElementById('comment'),
      txt = m.value || '',
  content = txt.replaceAll('\n', '%0A%0D');
  n.setAttribute('href', 'mailto:' + name + '@sceptique.fr?subject=Contact&body=' + content);
  n.click();
  event.stopPropagation();
  event.preventDefault();  
  return false;
}
