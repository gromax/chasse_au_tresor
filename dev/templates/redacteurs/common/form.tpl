<form>
	<% if (showInfos){ %>
	<div class="form-group">
		<label for="item-nom" class="control-label">Nom :</label>
		<input class="form-control" id="item-nom" name="nom" type="text" value="<%- nom %>" placeHolder="Nom"/>
	</div>

	<div class="form-group">
		<label for="item-email" class="control-label">@ :</label>
		<input class="form-control" id="item-email" name="email" type="text" value="<%- email %>" placeHolder="email"/>
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
</form>
