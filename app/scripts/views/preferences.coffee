_ = require "underscore"

Bounce = require "bounce"
BaseView = require "scripts/views/base"
ComponentView = require "scripts/views/component"
Events = require "scripts/events"

template = require "templates/preferences"

class PreferencesView extends BaseView
  el: "#preferences"
  template: template
  components: []

  events:
    "click #add": "onClickAdd"
    "change .preset-input": "onChoosePreset"

  initialize: ->
    super
    @$components = @$ ".components"
    @$presets = @$ ".preset-input"

    @$presets.chosen disable_search: true
    @$presets.on "chosen:updated", @onChoosePreset

    $(window).on "resize", @setHeight

    @appendComponent()

  onClickAdd: ->
    @appendComponent()

  appendComponent: (component) ->
    componentView = new ComponentView component: component
    @$components.append componentView.$el
    @components.push componentView
    @setHeight()

  clearComponents: ->
    component.remove() for component in @components
    @$components.empty()
    @components = []

  setHeight: =>
    offsetTop = @$components.offset().top
    windowHeight = $(window).height()

    @$components.css "max-height", windowHeight - offsetTop - 50

  getBounceObject: =>
    bounce = new Bounce
    @components.map (c) -> c.addToBounce bounce
    bounce

  setFromBounceObject: (bounce) ->
    @clearComponents()
    for component in bounce.components
      @appendComponent component

  onChoosePreset: =>
    Events.trigger "selectedPresetAnimation", @$presets.val()
    Events.off ".presetEvent"
    Events.once "animationOptionsChanged", @clearPreset

  selectPreset: (preset) ->
    $preset = @$presets.find "option[data-name=\"#{preset}\"]"
    @$presets.val($preset.attr("value")).trigger "chosen:updated"

  clearPreset: =>
    Events.off "animationOptionsChanged", @clearPreset
    @$presets.val("").trigger "chosen:updated"

module.exports = PreferencesView
