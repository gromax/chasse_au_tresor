<h2><%- evenement.titre %></h2>
<p><%- evenement.description%></p>

<% if (cle!=""){%>
<div class="alert alert-danger" role="alert">
  Vous avez essayé <b><%- cle %></b>.<br>
  <strong>Raté !</strong> Essayez encore...
</div>
<%}%>

<div>
<% _.each(startCles, function(item){%>
<a href="#" class="badge badge-success js-startCle" cle="<%-item%>"><%-item%></a>
<%});%>
</div>
<i>Il faudra ajouter les informations début/fin/durée</i>
