<form id="essai-form" class="" style="margin-bottom: 10px;">
  <div class="input-group">
    <input type="text" class="form-control search-query js-essai" placeholder="Essayer..." value="<%- cle %>" <%if (!actif) {%>disabled<%}%>>
    <div class="input-group-append">
      <button class="btn btn-primary" type="submit" title="lancer l'essai" <%if (!actif) {%>disabled<%}%>><i class="fa fa-search"></i></button>
      <button class="btn btn-primary js-gps" type="button" title="géolocalisation" <%if (!actif) {%>disabled<%}%>><i class="fa fa-map-marker"></i></button>
    </div>

  </div>
   <%if (!actif) {%><small class="form-text text-muted"><i class="fa fa-exclamation-triangle"></i>&nbsp;L'événement est verrouillé.</small><%}%>
</form>
