require 'spec_helper'
require 'jshint/configuration'

describe Jshint::Configuration do
  subject { described_class.new(config) }

  describe "core behaviour" do
    let(:config) { File.expand_path('../../fixtures/jshint.yml', __FILE__) }

    it "should allow the developer to index in to config options" do
      expect(subject[:boss]).to be_truthy
      expect(subject[:browser]).to be_truthy
    end

    it "should return a Hash of the global variables declared" do
      expect(subject.global_variables).to eq({ "jQuery" => true, "$" => true })
    end

    it "should return a Hash of the lint options declared" do
      expect(subject.lint_options).
        to eq(subject.options["options"].reject { |key| key == "globals" })
    end

    it "should return an array of files" do
      expect(subject.files).to eq(["**/*.js"])
    end

    context "search paths" do
      it "should default the exclusion paths to an empty array" do
        expect(subject.excluded_search_paths).to eq([])
      end

      it "should set the exclusion paths to those in the config" do
        subject.options["exclude_paths"] << 'vendor/assets/javascripts'
        expect(subject.excluded_search_paths).to eq(["vendor/assets/javascripts"])
      end

      it "should be the default search paths minus the exclude paths" do
        expect(subject.search_paths).to eq(subject.default_search_paths)
        subject.options["exclude_paths"] << 'vendor/assets/javascripts'
        expect(subject.search_paths).
          to eq(['app/assets/javascripts', 'lib/assets/javascripts'])
      end
    end
  end

  describe "with JSON configuration file" do
    let(:config) { File.expand_path('../../fixtures/.jshintrc', __FILE__) }

    it "should return a Hash of the global variables declared" do
      expect(subject.global_variables).to eq({ "jQuery" => false, "$" => true })
    end

    it "should return a Hash of the lint options declared" do
      expect(subject.lint_options["camelcase"]).to eq(true)
      expect(subject.lint_options["plusplus"]).to eq(false)
    end

    it "should include all js files" do
      expect(subject.files).to eq(["**/*.js"])
    end

    it "should exclude nothing" do
      expect(subject.excluded_search_paths).to eq([])
    end
  end
end
