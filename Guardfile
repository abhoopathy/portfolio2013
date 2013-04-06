require 'image_optim'

guard 'livereload' do
  watch(%r{_site/.+\.(css|js|html)})
end

guard 'shell' do
    print('task2')
    watch %r{^_assets/.+\.(png|jpg|jpeg|gif)} do |file|
        n file[0], "#{file[0]} changed"
        ImageOptim.new.optimize_image!(file[0])
    end
end
