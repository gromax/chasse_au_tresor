<div class="card">
<div class="card-header text-white bg-primary"><h3><%- titre %></h3></div>
<div class="card-body">
<p class="card-text"><strong>description :</strong> <%- description %></p>
<% if (typeof nomProprietaire != "undefined") { %>
<p class="card-text"><strong>Propriétaire :</strong> <%- nomProprietaire %></p>
<% } %>
<% if (actif) { %>
<p class="card-text"><strong>Actif</strong></p>
<% } else { %>
<p class="card-text"><strong>Inactif</strong></p>
<% } %>
</div>
</div>
