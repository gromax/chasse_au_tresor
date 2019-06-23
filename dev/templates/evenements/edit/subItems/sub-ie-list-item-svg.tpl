<% if (redacteurMode) {%>
<div class="card-header">
  <ul class="nav nav-pills card-header-pills">
    <li class="nav-item">
      <a class="nav-link js-up" href="#"><i class="fa fa-long-arrow-up"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-down" href="#"><i class="fa fa-long-arrow-down"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-delete" href="#"><i class="fa fa-trash"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-edit <% if (editMode) {%>active<%}%>" href="#"><i class="fa fa-pencil"></i></a>
    </li>
    <li class="nav-item">
      <a class="nav-link js-show <% if (!editMode) {%>active<%}%>" href="#"><i class="fa fa-eye"></i></a>
    </li>
  </ul>
</div>
<% }
if(editMode){%>
<div class="card-body">
  Édition type svg
</div>
<%} else {%>
<div class="card-body">
  Affichage type svg
</div>
<%}%>
