<h2><%- evenement.titre %></h2>
<p><%- evenement.description%></p>

<%
if (cle!=""){
  if (gps){
%><div class="alert alert-danger" role="alert">
  Vous avez essayé une localisation gps.<br>
  <strong>Raté !</strong><br>
<% if (accuracy>GPS_LIMIT) {%>
  Votre géolocalisation n'est pas assez précise : <%- accuracy %> mètres.<br>
  L'erreur maximum autorisée est de <%-GPS_LIMIT %> mètres.<br>
<% } else {%>
  La précision est de <%-GPS_LIMIT %> mètres.<br>
  Essayez de vous rapprocher...
<% } %>
</div><%
  } else {
%><div class="alert alert-danger" role="alert">
  Vous avez essayé <b><%- cle %></b>.<br>
  <%
    if ((!evenement.actif)&&(!cleSaved)){
      %><strong>L'événement est verrouillé.</strong><br>Vous ne pouvez pas faire de nouveaux essais pour l'instant.<%
    } else { if (evenement.sauveEchecs && (evenement.ptsEchecs<0)) {
      %><strong>Raté !</strong> Attention aux pénalités.<% if (evenement.actif){ %> Essayez encore...<% }
    } else {
      %><strong>Raté !</strong><% if (evenement.actif){ %> Essayez encore...<% }
    }}%>
</div><%
  }
}
%>

<p class="text-warning">Vous n'avez pas encore terminé cette partie. <b>Début :</b> <%-dateDebut %></p>
<p class="text-info"><b>Aide :</b> Essayez des mots dans le champ de saisie ; cliquez sur les clés données ci-dessous pour démarrer ; retrouvez les clés que vous avez déjà proposées dans la liste en haut.</p>

