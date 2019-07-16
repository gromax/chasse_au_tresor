<h1 class="display-4"><%if (!actif) { %><i class="fa fa-lock"></i>&nbsp;<% } %><%-titre%></h1>
<p class="lead"><%-description%></p>
<hr class="my-4">
<%
if (actif) {
  if (hasPartie) {
%><p>Vous avez déjà commencé cette partie. Cliquez le lien pour la continuer !</p>
<a class="btn btn-primary btn-lg js-continue" href="#" role="button">Continuer</a><%
  } else {
%><p>Si vous êtes prêt à démarrer, c'est ici !</p>
<button type="button" class="btn btn-primary js-start">Démarrer</button><%
  }
} else {
  if (hasPartie) {
%><p>Cette partie est maintenant verrouillée. Vous ne pouvez pas la modifier.</p>
<a class="btn btn-primary btn-lg js-continue" href="#" role="button">Voir</a><%
  } else {
%><p class="text-danger">Cet événément est verrouillé pour l'instant.</p><%
  }
}
%>
