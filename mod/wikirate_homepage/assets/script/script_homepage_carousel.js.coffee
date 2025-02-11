$(document).ready ->
  animateHeaderText = ->
    $flipTexts = $('.flip-this')
    animationDelay = 2000 # ms; delay between each flip
    animationDuration = 1000 # ms; how fast it should flip
    staggerInterval = 250 # (animationDelay + animationDuration) / $flipTexts.length

    $flipTexts.each (i) ->
      $item = $(this)

      # set queue for animation
      setTimeout (->
        $item.parent().removeClass('loading-text')
        $item.show()
        $item.wodry_wikirate
          animation: 'rotateX'
          delay: animationDelay
          animationDuration: animationDuration
      ), 400 + staggerInterval * i


  animateHeaderText()

  numberElements = getNumberElements() #elements for animation

  animationNumbers = () ->
    numberElements.forEach (elem) ->
      # if the element is not animated and is visible
      if (!isAnimated($(elem).attr('id')) && isScrolledIntoView(elem))
        animateElem($(elem).attr('id'))
        runAnimation(elem)

  animationNumbers()

  $(document).on 'scroll', () ->
    animationNumbers()

  #options = { useEasing: true, useGrouping: true, separator: ',', decimal: '.', };
  #demo = new CountUp('myTargetElement', 0, 4775, 0, 2.5, options);
  #demo.start()

  # patch for bootstrap bug on homepage carousel tabs
  # After the upgrade to Bootstrap 4, the "previous" tabs were not getting deactivated properly.
  # This may be because of an interaction between the tabs and the carousels inside them (?)
  # the following restores the expected behavior by removing the active class from the previous tab.
  # it also deals with a follow-up problem in which carousel items were not activating correctly
  $('body').on 'shown.bs.tab', '.intro-tabs .nav-link', (e)->
    activateIntroTab this

activateIntroTab = (tab)->
  panels = $('.intro-tab-panels .tab-pane')
  target = $(tab).data 'target'

  other_panels = panels.not target
  other_panels.removeClass 'active'
  other_panels.find('.carousel').carousel('pause')

  panels.find('.carousel-item').removeClass 'active'

  active_panel = panels.filter target
  active_panel.find('.carousel').carousel()
  active_panel.find('.carousel-item').first().addClass 'active'

getNumberElements = () ->
  values = []
  $('._count-ele').each ->
    values.push( $(this) )
    controlAnimate($(this))
  values

isScrolledIntoView = (elem) ->
  docViewTop = $(window).scrollTop();
  docViewBottom = docViewTop + $(window).height();
  elemTop = $(elem).offset().top;
  elemBottom = elemTop + $(elem).height();
  ((elemBottom <= docViewBottom) && (elemTop >= docViewTop));

runAnimation = (elem) ->
  options = { useEasing: true, useGrouping: true, separator: ',', decimal: '.', };
  animationNumber = new CountUp($(elem).attr('id'),  0, parseInt($(elem).text()), 0, 3.5, options);
  animationNumber.start()

controlAnimate = (elem) ->
  numberElementsControls.push( {id: $(elem).attr('id'), animated: false} )

# has this element been animated?
isAnimated = (id) ->
  aux = false
  numberElementsControls.forEach (elem) ->
    if elem.id == id && elem.animated
      aux = true
      return
  aux

# animate this element
animateElem = (id) ->
  numberElementsControls.forEach (elem) ->
    if elem.id == id
      elem.animated = true

# to determine if a specific element has been animated (in this array all the elements are saved)
# with an "animated" property, it can be "true" or "false"
numberElementsControls = []

# $('.intro-tab-panels .tab-pane').not().removeClass 'active'
    #    targetTab = $(e.target).data('target')
    #    console.log targetTab
    #    $(targetTab).find('.slick-next').trigger 'click'
