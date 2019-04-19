import Marionette from 'backbone.marionette'
import Syphon from 'backbone.syphon'
import templateAccueil from "templates/parties/show/accueil.tpl"
import templatePanel from "templates/parties/show/panel.tpl"
import templateLayout from "templates/parties/show/layout.tpl"

PanelView = Marionette.View.extend {
	template: templatePanel

	events: {
		"submit #essai-form": "essayerCle"
	}

	ui: {
		essai: "input.js-essai"
	}

	essayerCle: (e)->
		e.preventDefault()
		essai = @ui.essai.val()
		@trigger "essai", essai

	onSetCle: (cle)->
		@ui.essai.val(cle)

	templateContext: ->
		{
			cle: @options.cle ? ""
		}
}

AccueilView = Marionette.View.extend {
	template: templateAccueil
	events:{
		"click a.js-startCle": "clickStartCle"
	}

	clickStartCle: (e)->
		e.preventDefault()
		$el = $(e.currentTarget)
		@trigger("essai",$el.attr("cle"))

	templateContext: ->
		{
			evenement: _.clone(@options.evenement.attributes)
			startCles: @options.startCles
			cle: @options.cle ? ""
		}
}

Layout = Marionette.View.extend {
	template: templateLayout
	regions: {
		panelRegion: "#panel-region"
		motsRegion: "#mots-region"
		itemRegion: "#item-region"
	}
}

export { AccueilView, PanelView, Layout }

