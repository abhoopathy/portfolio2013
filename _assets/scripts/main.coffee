$window = $(window)

$ ->
    $('.img-carousel').each (i,el) ->
        $(el).children('.portfolio-img').each (i,img) ->
            if i > 0
                $img = $(img)
                source = $img.attr('src')
                source = $img.attr('data-src',source)
                $img.removeAttr('src')

## after image carousel plugin does its thing,
## so that page section sizes are correct
#
$window.load ->

    window.App =
        Views: {}
        Constants: {}
        Events: _.extend({},Backbone.Events)


    class Router extends Backbone.Router
        routes:
            'portfolio'                : 'portfolio'
            'resume'                   : 'resume'
            'contact'                  : 'contact'
            #'portfolio-piece-:pieceID' : 'portfolioPiece'

        portfolio: () ->
            App.Views.portfolioView.positionAbsolute()
            App.Views.headerView.positionFixed()

        resume: () ->
            App.Views.headerView.positionFixed()

        contact: () ->
            App.Views.headerView.positionFixed()

        #portfolioPiece: () ->
            #App.Views.headerView.positionFixed()
            #App.Views.portfolioView.positionFixed()


    class CarouselView extends Backbone.View

        currIndex: 0

        initialize: () ->
            _.bindAll(this)
            @$buttonPrev = $("<div class='img-carousel-button img-carousel-button-prev'><</div>")
            @$buttonNext = $("<div class='img-carousel-button img-carousel-button-next'>></div>")
            @$el.append @$buttonPrev
            @$el.append @$buttonNext
            @images = @$el.find('.portfolio-img')
            @$el.height(@images.first().height())
            @delegateEvents()

        events:
            'mouseover'                        : 'getImages'
            'click .img-carousel-button-next' : 'nextImage'
            'click .img-carousel-button-prev' : 'prevImage'

        getImages: () ->
            if !@imagesFetched
                @$('.portfolio-img').each (i,img) ->
                    if i > 0
                        $img = $(img)
                        source = $img.attr('data-src')
                        source = $img.attr('src',source)
                        $img.removeAttr('data-src')
            @imagesFetched=true

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


    class HeaderView extends Backbone.View

        el:$('.header-wrapper')
        fixed: false

        initialize: ->
            @$links = @$('.nav-list-item a')
            @headerHeight = @$el.outerHeight()

        offsetTop: -> @$el.offset().top

        positionFixed: ->
            @$el.addClass('fixed')

        positionAbsolute: ->
            @$el.removeClass('fixed')


    class PortfolioView extends Backbone.View

        el: $('#portfolio').closest('.page')
        sidebarMarginTop: 152
        sidebarMarginLeft: 30
        sidebarVisible: true

        initialize: ->
            _.bindAll(this)
            @$sidebar = @$('.sidebar-list-wrapper')
            @$sidebarLinks = @$sidebar.find('.sidebar-sub-list-item a')
            @sidebarAbsoluteMarginTop = @$sidebar.position().top
            @$('.img-carousel').each (i,el) -> new CarouselView {el: el}

            App.Events.on "windowSizeChange:mobile", @resizeMobile
            App.Events.on "windowSizeChange:desktop", @resizeDesktop
            App.Events.on "windowSizeChange", @windowResized

        windowResized: ->
            @$sidebar.css
                    left: @$el.offset().left + @sidebarMarginLeft

        resizeMobile: ->
            @sidebarVisible = false
            @$sidebar.hide()

        resizeDesktop: ->
            @sidebarVisible = true
            @$sidebar.show()

        offsetTop: -> @$sidebar.offset().top - @sidebarMarginTop
        offsetBottom: -> @$el.offset().top + @$el.height() - @$sidebar.height()

        positionFixed: ->
            @$sidebar.addClass('fixed')
                .css
                    left: @$el.offset().left + @sidebarMarginLeft
                    top: @sidebarMarginTop
            @$sidebar.fadeIn(100) if @sidebarVisible

        positionAbsolute: ->
            @$sidebar.removeClass('fixed')
                .css
                    left: @sidebarMarginLeft
                    top: @sidebarAbsoluteMarginTop
            @$sidebar.fadeIn(100) if @sidebarVisible

        fadeOut: ->
            @$sidebar.fadeOut(100)



    class AppView extends Backbone.View

        el: ('body')
        scrollRanges: []
        mobile: false
        windowWidth: document.documentElement.clientWidth
        resizeTimeout: null

        initialize: ->
            _.bindAll(this)
            @$calloutImage = @$('.callout-image')

            App.Views.headerView = new HeaderView()
            App.Views.portfolioView = new PortfolioView()

            #TODO remove hack when we have contact content
            @$('#contact').closest('.page').css
                'min-height': $window.height()

            #TODO add modernizr logic to this?
            @$('.page-anchor').css
                top: -1 * App.Views.headerView.headerHeight

            @setSizes()

            @scrolled = false
            window.setInterval @checkScroll, 30
            $window.scroll @handleWindowScroll

            $window.resize @handleWindowResize

        handleWindowResize: ->
            clearTimeout @resizeTimeout
            @resizeTimeout = setTimeout @resizeDone, 80

        resizeDone: ->
            @windowWidth = document.documentElement.clientWidth

            App.Events.trigger "windowSizeChange", @windowWidth

            if @windowWidth > 960 && @mobile
                @mobile = false
                App.Events.trigger "windowSizeChange:desktop", @windowWidth
            if @windowWidth <= 960 && !@mobile
                @mobile = true
                App.Events.trigger "windowSizeChange:mobile", @windowWidth

            @setSizes()

        checkScroll: ->
            scroll = $window.scrollTop()
            if @scrolled
                _.each @scrollRanges, (range) ->

                    # if only lower bound is defined
                    if range.lo? && !range.hi?

                        # if newly in range, trigger in range handler
                        if scroll >= range.lo
                            if range.current != 'inRange'
                                range.handle?(scroll)
                            range.current = 'inRange'

                        # if newly too low, trigger low handler
                        else
                            if range.current != 'low'
                                range.handleLo?(scroll)
                            range.current = 'low'

                    # if only higher bound is defined
                    else if !range.lo? && range.hi?

                        if scroll < range.hi
                            if range.current != 'inRange'
                                range.handle?(scroll)
                            range.current = 'inRange'

                        else
                            if range.current != 'hi'
                                range.handleHi?(scroll)
                            range.current = 'hi'

                    # if both bounds are defined
                    else if range.lo? && range.hi?

                        if range.lo <= scroll < range.hi
                            if range.current != 'inRange'
                                range.handle?(scroll)
                            range.current = 'inRange'

                        else if scroll < range.lo
                            if range.current != 'low'
                                range.handleLo?(scroll)
                            range.current = 'low'

                        else
                            if range.current != 'hi'
                                range.handleHi?(scroll)
                            range.current = 'hi'

            @scrolled = false


        handleWindowScroll: ->
            @scrolled = true
            scroll = $window.scrollTop()
            @$calloutImage.css {'background-position': "50% #{scroll}px"}


        setSizes: ->
            @scrollRanges = [
                {
                    lo: App.Views.headerView.offsetTop()
                    handle: -> App.Views.headerView.positionFixed()
                    handleLo: -> App.Views.headerView.positionAbsolute()
                },
                {
                    lo: App.Views.portfolioView.offsetTop()
                    hi: App.Views.portfolioView.offsetBottom()
                    handle: -> App.Views.portfolioView.positionFixed()
                    handleLo: -> App.Views.portfolioView.positionAbsolute()
                    handleHi: -> App.Views.portfolioView.fadeOut()
                }
            ]

            @addLinkAnchorRanges(App.Views.headerView.$links,
                App.Views.headerView.headerHeight, 'page', true)

            @addLinkAnchorRanges(App.Views.portfolioView.$sidebarLinks,
                App.Views.headerView.headerHeight, 'portfolio-piece')

            setSizes: -> $window.trigger('scroll')

        addLinkAnchorRanges: ($links, offset, parentClass, navigate) ->
            _.each $links, ((link, i) ->
                $link = $(link)
                pageID = $(link).attr('href')
                $page = $(pageID).closest('.'+parentClass)
                lo = $page.offset().top
                hi = lo + $page.outerHeight()
                rangeData =
                    lo: lo - offset
                    hi: hi - offset
                if i == 0
                    rangeData.handleLo = -> $links.removeClass('active')
                if navigate
                    rangeData.handle = ->
                        $links.removeClass('active')
                        $link.addClass('active')
                else
                    rangeData.handle = ->
                        $links.removeClass('active')
                        $link.addClass('active')

                @scrollRanges.push rangeData
            ), this


    # Initialize Everything!
    App.initialize = ->
        App.Views.appView = new AppView()
        App.Router = new Router()
        Backbone.history.start()

    App.initialize()
