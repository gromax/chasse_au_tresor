<div class="card-body">
	<form>
		<div class="form-group row">
			<label for="user-email" class="col-form-label col-sm-3">Email / Identifiant</label>
			<div class="col-sm-9">
				<input type="input" class="form-control" name="email" id="user-email" placeholder="Entrez un email" value="">
			</div>
		</div>

		<div class="form-group row">
			<label for="user-pwd" class="col-form-label col-sm-3">Mot de passe</label>
			<div class="col-sm-9">
				<input type="password" class="form-control" name="pwd" id="user-pwd" placeholder="Entrez un mot de passe">
			</div>
		</div>

		<div class="form-check">
			<input type="checkbox" class="form-check-input" id="admCheck">
			<label class="form-check-label" for="admCheck" name="adm">Je suis un rédacteur</label>
		</div>
		<button type="submit" class="btn btn-primary js-submit">Valider</button>
		<div id="messages"></div>
	</form>
</div>
