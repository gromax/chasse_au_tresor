<form>
	<% if (showInfos){ %>
	<div class="form-group">
		<label for="item-nom" class="control-label">Nom(s) :</label>
		<input class="form-control" id="item-nom" name="nom" type="text" value="<%- nom %>" placeHolder="Nom"/>
	</div>

	<div class="form-group">
		<label for="item-username" class="control-label">identifiant ou email :</label>
		<input class="form-control" id="item-username" name="username" type="text" value="<%- username %>" placeHolder="email / indentifiant"/>
	</div>
	<%}%>

	<% if (showPWD){ %>
	<div class="form-group">
		<label for="item-pwd" class="control-label">Mot de passe :</label>
		<input class="form-control" id="item-pwd" name="pwd" type="password" value="" placeHolder="Mot de passe"/>
	</div>
	<div class="form-group">
		<label for="item-pwdConfirm" class="control-label">Confirmation :</label>
		<input class="form-control" id="item-pwdConfirm" name="pwdConfirm" type="password" value="" placeHolder="Mot de passe"/>
	</div>
	<%}%>

	<button class="btn btn-success js-submit">Enregistrer</button>
	<% if (showToggle) {
		if (showInfos && !showPWD) {
			%><a href="#" class="btn btn-outline-success js-toggle" role="button">Modifier le mot de passe</a><%
		} else if (showPWD && !showInfos){
			%><a href="#" class="btn btn-outline-success js-toggle" role="button">Modifier nom / identifiant</a><%
		}
	}%>
</form>
