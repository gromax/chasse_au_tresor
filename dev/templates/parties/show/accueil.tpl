<h2><%- evenement.titre %></h2>
<p><%- evenement.description%></p>

<%
if (cle!=""){
  if (gps){
%><div class="alert alert-danger" role="alert">
  Vous avez essayé une localisation gps.<br>
  <strong>Raté !</strong><br>
<% if (accuracy>25) {%>
  Votre géolocalisation n'est pas assez précise : <%- accuracy %> mètres.<br>
  L'erreur maximum autorisée est de 25 mètres.<br>
<% } else {%>
  La précision est de 25 mètres.<br>
  Essayez de vous rapprocher...
<% } %>
</div><%
  } else {
%><div class="alert alert-danger" role="alert">
  Vous avez essayé <b><%- cle %></b>.<br>
  <strong>Raté !</strong> Essayez encore...
</div><%
  }
}
%>

<% if (fini) {%>
<div class="alert alert-success" role="alert">
  Vous avez commencé terminé cette partie !<br>
  <b>Début :</b> <%-dateDebut %><br>
  <b>Fin :</b> <%-dateFin %><br>
</div>
<% } else { %>
<p class="text-warning">Vous n'avez pas encore terminé cette partie. <b>Début :</b> <%-dateDebut %></p>
<p class="text-info"><b>Aide :</b> Essayez des mots dans le champ de saisie ; cliquez sur les clés données ci-dessous pour démarrer ; retrouvez les clés que vous avez déjà proposées dans la liste en haut.</p>
<% } %>

<div>
<h5>Clés pour démarrer</h5>
<% _.each(startCles, function(item){%>
<a href="#" class="badge badge-success js-startCle"><%-item%></a>
<%});%>
</div>
