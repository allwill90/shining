require File.join(File.dirname(__FILE__), 'spec_helper')

describe 'shine' do
  PRESO = Dir.tmpdir/'shining-tmp'/'preso'
  SHINE = ROOT/'bin'/'shine'
  
  def new_preso
    system "#{SHINE} #{PRESO}"
  end
  
  def vendorize
    system "cd #{PRESO} && #{SHINE} vendor"
  end
  
  def new_slide(name)
    system "cd #{PRESO} && #{SHINE} slide #{name}"
  end
  
  def compile_templates
    system "cd #{PRESO} && #{SHINE} compile"
  end
  
  def make_haml_template!(name)
    File.open(PRESO/'slides'/"#{name}.haml", 'w') { |f| f << "%p LOOK MA" }
  end
  
  before :all do
    FileUtils.rm_rf   Dir.tmpdir/'shining-tmp'
    FileUtils.mkdir_p Dir.tmpdir/'shining-tmp'
  end
  
  before :each do
    FileUtils.rm_rf PRESO
    new_preso
  end
  
  it "creates a new shining preso when passing an argument thats not 'build', 'compile', or 'slide'" do
    File.directory?(PRESO).should == true
  end
  
  describe 'the slide option' do
    it "creates a new slide and slide script named 'foo' on 'shine slide foo'" do
      new_slide 'foo'
      File.exists?(PRESO/'slides'/'foo.html').should be_true
      File.exists?(PRESO/'slides'/'foo.js').should be_true
    end
    
    it "updates the presentation's config file with the slide added" do
      new_slide 'test'
      config = JSON.parse(File.read(PRESO/'config.json'))
      config['slides'].should include('test')
    end
    
    it "won't let you create a slide with the same name of an already existing one"
  end
  
  it "vendorizes Shining to #{PRESO/'vendor'} with the 'vendor' option" do
    vendorize
    %w(lib themes css).each do |required|
      File.exists?(PRESO/'vendor'/required).should be_true
    end
  end
  
  it "compiles a Haml template if there is one in #{'PRESO_ROOT'/'slides'/'test.haml'} with the 'compile' option" do
    make_haml_template! 'test'
    compile_templates    
    File.read(PRESO/'slides'/'test.html').should == "<p>LOOK MA</p>\n"
  end  
end