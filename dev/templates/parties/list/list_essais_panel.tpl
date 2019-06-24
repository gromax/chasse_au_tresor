<div class="card-header text-white bg-primary"><h3><a href="#" class="btn btn-dark js-parent" role="button" title="Liste des événements"><i class="fa fa-level-up"></i></a>&nbsp;<span class="badge badge-pill badge-danger"><%- idPartie %></span>&nbsp; <%- titreEvenement %></h3></div>
<div class="card-body">
<p class="card-text"><strong>description :</strong> <%- descriptionEvenement %></p>
<p class="card-text"><strong>Joueur :</strong> <%- nomJoueur %></p>
<% if (actif) { %>
<p class="card-text"><strong>Événement actif</strong></p>
<% } else { %>
<p class="card-text"><strong>Événement inactif</strong></p>
<% } %>
<h2><span class="badge badge-pill badge-danger">Score : <%- score %></span></h2>
</div>
