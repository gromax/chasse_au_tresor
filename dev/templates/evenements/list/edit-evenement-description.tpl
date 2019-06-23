<form>
	<div class="form-group">
		<label for="item-titre" class="control-label">Titre :</label>
		<input class="form-control" id="item-titre" name="titre" type="text" value="<%- titre %>" placeHolder="Nom"/>
	</div>
	<div class="form-group">
		<label for="item-description" class="control-label">Description :</label>
			<textarea class="form-control" id="item-description" name="description" rows="3" placeHolder="Description"><%- description %></textarea>
	</div>

	<button class="btn btn-success js-submit">Enregistrer</button>
</form>
