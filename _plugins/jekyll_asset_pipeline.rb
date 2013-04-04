require 'jekyll_asset_pipeline'

module JekyllAssetPipeline

    class CoffeeScriptConverter < JekyllAssetPipeline::Converter
        require 'coffee-script'
        def self.filetype
            '.coffee'
        end

        def convert
            return CoffeeScript.compile(@content)
        end
    end

    class StylusConverter < JekyllAssetPipeline::Converter
        require 'stylus'
        #require 'stylus-nib'

        def self.filetype
            '.styl'
        end

        def convert
            return Stylus.compile(@content, :compress => true)
        end
    end

end
