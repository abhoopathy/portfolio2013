$window = $(window)

$window.load ->

    ## hack to make last section at least size of page
    $('.page#contact').css
        'min-height': $window.height()

    window.App =
        Views: {}
        Constants: {}

    App.Router = Backbone.Router.extend
        routes:
            "": ""

    class CarouselView extends Backbone.View

        currIndex: 0

        initialize: () ->
            _.bindAll(this)
            @$buttonPrev = $("<div class='img-carousel-button img-carousel-button-prev'><</div>")
            @$buttonNext = $("<div class='img-carousel-button img-carousel-button-next'>></div>")
            @$el.append @$buttonPrev
            @$el.append @$buttonNext
            @$buttonPrev.click @prevImage
            @$buttonNext.click @nextImage
            @images = @$el.find('.portfolio-img')
            @$el.height(@images.first().height())

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
            App.Constants.HEADER_HEIGHT= @$el.outerHeight()

        offsetTop: -> @$el.offset().top

        positionFixed: ->
            if !@fixed
                @fixed=true
                @$el.addClass('fixed')

        positionAbsolute: ->
            if @fixed
                @fixed=false
                @$el.removeClass('fixed')


    class PortfolioView extends Backbone.View

        el: $('.page#portfolio')
        visible: true
        fadedIn: true
        sidebarMarginTop: 150
        sidebarMarginLeft: 30

        initialize: ->
            @$sidebar = @$('.sidebar-list-wrapper')
            @$sidebarLinks = @$sidebar.find('.sidebar-sub-list-item a')
            @$('.img-carousel').each (i,el) -> new CarouselView {el: el}

        offsetTop: -> @$sidebar.offset().top - @sidebarMarginTop
        offsetBottom: -> @$el.offset().top + @$el.height() - @$sidebar.height()

        positionFixed: ->
            if !@fixed
                @fixed=true
                @$sidebar
                    .addClass('fixed')
                    .css
                        left: @$el.offset().left + @sidebarMarginLeft
                        top: @sidebarMarginTop
            else if !@fadedIn
                @fadedIn=true
                @$sidebar.fadeIn(100)

        positionAbsolute: ->
            if @fixed
                @fixed=false
                @$sidebar.removeClass('fixed')
                    .css
                        left: @sidebarMarginLeft
                        top: 216
        resize: ->
            if @fixed
                @$sidebar.css
                        left: @$el.offset().left + @sidebarMarginLeft
                        top: @sidebarMarginTop

        fadeOut: ->
            if @fadedIn
                @fadedIn=false
                @$sidebar.fadeOut(100)

    $calloutImage = $('.callout-image')
    App.Views.headerView = new HeaderView()

    App.Views.portfolioView = new PortfolioView()

    App.scrollRanges = []
    setSizes = ->
        App.scrollRanges = [
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
            {
                lo: -100
                hi: App.Views.portfolioView.offsetTop()
                handle: (scroll) -> $calloutImage.css {'background-position': "50% #{scroll}px"}
            }
        ]

        addLinkAnchorRanges = ($links, offset) ->
            _.each $links, (link, i) ->
                $link = $(link)
                pageID = $(link).attr('href')
                $page = $("#{pageID}")
                lo = $page.offset().top
                hi = lo + $page.outerHeight()
                rangeData =
                    lo: lo - offset
                    hi: hi - offset
                    handle: ->
                        $links.removeClass('active')
                        $link.addClass('active')
                if i == 0
                    rangeData.handleLo = -> $links.removeClass('active')
                App.scrollRanges.push rangeData

        addLinkAnchorRanges(App.Views.headerView.$links, App.Constants.HEADER_HEIGHT)
        addLinkAnchorRanges(App.Views.portfolioView.$sidebarLinks, App.Constants.HEADER_HEIGHT)


    setSizes()
    $window.resize ->
        setSizes()
        App.Views.portfolioView.resize()




    $window.scroll (e)->
        scroll = $window.scrollTop()

        _.each App.scrollRanges, (range) ->

            if range.lo? && !range.hi?
                if scroll >= range.lo
                    range.handle(scroll) if range.handle?
                else
                    range.handleLo(scroll) if range.handleLo?

            else if !range.lo? && range.hi?
                if scroll < range.hi
                    range.handle(scroll) if range.handle?
                else
                    range.handleHi(scroll) if range.handleHi?

            else if range.lo? && range.hi?
                if range.lo <= scroll < range.hi
                    range.handle(scroll)
                else if scroll < range.lo
                    range.handleLo(scroll) if range.handleLo?
                else
                    range.handleHi(scroll) if range.handleHi?

