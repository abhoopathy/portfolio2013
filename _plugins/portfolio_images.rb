require 'pry'

module Jekyll

    class PortfolioImage < Liquid::Tag
        def initialize(tag_name, text, tokens)
            super
            @text = text
        end

        def render(context)
            page_url = context.environments.first["page"]["id"]
            page_name = page_url.match(/\/([A-Za-z-]+)$/)[1].downcase()
            return "<img class=\"portfolio-img\" src=\"assets/portfolio_images/#{page_name}/#{@text}\"/>"
        end
    end

end

Liquid::Template.register_tag('portfolio_image', Jekyll::PortfolioImage)
