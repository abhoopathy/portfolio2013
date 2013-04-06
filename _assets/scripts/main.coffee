$(window).load ->
    $window = $(window)
    $portfolio = $('.page#portfolio')

    portfolioTop = -1
    portfolioLeft = -1
    resumeTop = -1

    setSizes = ->
        portfolioTop = $portfolio.offset().top + 216 - 100
        portfolioLeft = $portfolio.offset().left
        resumeTop = portfolioTop + $portfolio.height() - $('.sidebar-list-wrapper').height()

    setSizes()
    $window.resize ->
        setSizes()


    class Carousel

        constructor: (el) ->
            _.bindAll(this)
            @$el = $(el)

            @$buttonPrev = $("<div class='img-carousel-button img-carousel-button-prev'><</div>")
            @$buttonNext = $("<div class='img-carousel-button img-carousel-button-next'>></div>")
            @$el.append @$buttonPrev
            @$el.append @$buttonNext
            @$buttonPrev.click @prevImage
            @$buttonNext.click @nextImage

            @images = @$el.find('.portfolio-img')
            @resize()


        resize: ->
            @$el.height(@images.first().height())
            #@images.each (i,img) ->
                #$img = $(img)
                #$img.css
                    #'margin-left': ($img.width()/-2)
                    #'margin-top': ($img.height()/-2)
                    #top 50%
                    #left 50%
                    #margin 0
                    #position absolute

        currIndex: 0

        step: (i1,i2)->
            $(@images[i1]).hide()
            $(@images[i2]).show()

        nextImage: ->
            i1 = @currIndex
            if @currIndex < @images.length - 1
                @currIndex=@currIndex+1
            else
                @currIndex=0
            @step(i1, @currIndex)

        prevImage: ->
            i1 = @currIndex
            if @currIndex > 0
                @currIndex=@currIndex-1
            else
                @currIndex=@images.length-1
            @step(i1, @currIndex)


    $('#portfolio .img-carousel').each (i,el) -> new Carousel(el)

    header =
        $el:$('header')

        atTop: true
        mouseIsOver: false

        show: -> @$el.addClass 'visible'
        hide: -> @$el.removeClass 'visible'

        pageScrollTop: ->
            @atTop = true
            @show()

        pageScrollNotTop: ->
            @atTop = false
            @hide() unless @mouseIsOver

        mouseenter: ->
            @mouseIsOver = true
            @show()

        mouseleave: ->
            @mouseIsOver = false
            @hide() unless @atTop

        init: ->
            _.bindAll(this)
            @$el.hover(@mouseenter,@mouseleave)

    header.init()


    portfolioSideBar =
        $el: $('.sidebar-list-wrapper')

        visible: true
        fadedIn: true

        positionFixed: ->
            if !@fixed
                @fixed=true
                @$el
                    .addClass('fixed')
                    .css
                        left: $portfolio.offset().left
                        top: 100
            else if !@fadedIn
                @fadedIn=true
                @$el.fadeIn(100)

        positionAbsolute: ->
            if @fixed
                @fixed=false
                @$el.removeClass('fixed')
                    .css
                        left: 0
                        top: 216
        fadeOut: ->
            if @fadedIn
                @fadedIn=false
                @$el.fadeOut(100)


    $window.scroll (e)->
        scroll = $window.scrollTop()

        #if scroll < 100
            #header.pageScrollTop()
        #else
            #header.pageScrollNotTop()

        if portfolioTop < scroll < resumeTop
            portfolioSideBar.positionFixed()
        else if scroll <= portfolioTop
            portfolioSideBar.positionAbsolute()

        else
            portfolioSideBar.fadeOut()



