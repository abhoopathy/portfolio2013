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

    #class CssCompressor < JekyllAssetPipeline::Compressor
        #require 'yui/compressor'

        #def self.filetype
            #'.css'
        #end

        #def compress
            #return YUI::CssCompressor.new.compress(@content)
        #end
    #end


    #class JavaScriptCompressor < JekyllAssetPipeline::Compressor
        #require 'closure-compiler'

        #def self.filetype
            #'.js'
        #end

        #def compress
            #return Closure::Compiler.new.compile(@content)
        #end
    #end

end
