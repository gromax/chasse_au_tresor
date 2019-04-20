<div class="card-header">
Inscription
</div>
<div class="card-body">
	<form>
		<div class="form-group row">
			<label for="user-email" class="col-form-label col-sm-3">Email / Identifiant</label>
			<div class="col-sm-9">
				<input type="input" class="form-control" name="email" id="user-email" placeholder="Entrez un email" value="">
				<div class="invalid-feedback">
					Déjà pris, trop court, trop nul...
				</div>
			</div>
		</div>

		<div class="form-group row">
			<label for="user-nom" class="col-form-label col-sm-3">Nom tel qu'il apparaîtra dans le jeu</label>
			<div class="col-sm-9">
				<input type="input" class="form-control" name="nom" id="user-nom" placeholder="Entrez un nom" value="">
				<div class="invalid-feedback">
					Trop court, trop nul...
				</div>
			</div>
		</div>

		<div class="form-group row">
			<label for="user-pwd" class="col-form-label col-sm-3">Mot de passe</label>
			<div class="col-sm-9">
				<input type="password" class="form-control" name="pwd" id="user-pwd" placeholder="Entrez un mot de passe">
				<div class="invalid-feedback">
					Pas assez compliqué.
				</div>
			</div>
		</div>

		<div class="form-group row">
			<label for="user-pwd-2" class="col-form-label col-sm-3">Mot de passe</label>
			<div class="col-sm-9">
				<input type="password" class="form-control" id="user-pwd-2" placeholder="Entrez un mot de passe">
				<div class="invalid-feedback">
					Les mots de passe ne correspondent pas.
				</div>
			</div>
		</div>

		<div class="form-check">
			<input type="checkbox" class="form-check-input" id="nrCheck">
			<label class="form-check-label" for="nrCheck">Je ne suis pas un robot</label>
			<div class="invalid-feedback">
				Robots interdits !
			</div>
		</div>

		<button type="submit" class="btn btn-primary js-submit">Valider</button>
		<div id="messages"></div>
	</form>
</div>
<div class="card-footer text-muted">
	Vous êtes libre d'entrer un simple nom d'utilisateur ou un email. Si vous donnez un email, il ne servira qu'à une chose : vous permettre de vous reconnecter en cas d'oubli. Les seules données conservées seront vos réponses aux différentes énigmes. Vous pourrez toujours effacer une partie ou même effacer votre compte, aucune trace n'en sera gardée.
</div>