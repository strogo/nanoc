module Nanoc::LayoutProcessor::Markaby
  class MarkabyLayoutProcessor < Nanoc::LayoutProcessor

    identifiers :markaby
    extensions  '.mab'

    def run(layout)
      nanoc_require 'markaby'

      assigns = { :page => @page, :pages => @pages, :config => @config, :site => @site }

      ::Markaby::Builder.new(assigns).instance_eval(layout).to_s
    end

  end
end