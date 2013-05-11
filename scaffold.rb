begin
  require 'nokogiri'
rescue LoadError
  puts "============ note ============="
  puts "looks like you don't have nokogiri installed, to use the scaffolding capabilities of Oak, you'll need to run the command 'gem install nokogiri', type 'rake -D gen' for more information on scaffolding (source located in scaffold.rb)."
  puts "================================"
  puts ""
end

namespace :gen do
  desc "adds a dynamic model class to your mvc project"
  task :model, [:name] => :rake_dot_net_initialize do |t, args|
    raise "name parameter required, usage: rake gen:model[Person]" if args[:name].nil?

    folder "Models"
    
    save model_template(args[:name]), "#{@mvc_project_directory}/Models/#{args[:name]}.cs"

    add_compile_node :Models, args[:name]
  end

  desc "adds a dynamic repository class to your mvc project"
  task :repo, [:name] => :rake_dot_net_initialize do |t, args|
    raise "name parameter required, usage: rake gen:repository[People]" if args[:name].nil?

    folder "Repositories"

    save repo_template(args[:name]), "#{@mvc_project_directory}/Repositories/#{args[:name]}.cs"

    add_compile_node :Repositories, args[:name]
  end

  desc "adds a controller class to your mvc project"
  task :controller, [:name] => :rake_dot_net_initialize do |t, args|
    raise "name parameter required, usage: rake gen:controller[PeopleController]" if args[:name].nil?

    folder "Controllers"

    save controller_template(args[:name]), "#{@mvc_project_directory}/Controllers/#{args[:name]}.cs"

    add_compile_node :Controllers, args[:name]
  end

  desc "adds cshtml to your mvc project"
  task :view, [:controller_and_name] => :rake_dot_net_initialize do |t, args|
    controller = args[:controller_and_name].split(':').first
    name = args[:controller_and_name].split(':').last

    raise "controller and view name required, usage: rake gen:view[Home:Index]" if args[:controller_and_name].split(':').count == 1

    folder "Views/#{controller}"

    save view_template(name), "#{@mvc_project_directory}/Views/#{controller}/#{name}.cshtml"

    add_cshtml_node controller, name
  end

  desc "adds a test file to your test project"
  take :test, [:name] => :rake_dot_net_initialize do |t, args|
    raise "name parameter required, usage: rake gen:test[decribe_HomeController]" if args[:name].nil?

    save controller_template(args[:name]), "#{@mvc_project_directory}/Controllers/#{args[:name]}.cs"

    add_compile_node :Controllers, args[:name]
  end

  def save content, file_path
    raise "#{file_path} already exists, cancelling" if File.exists? file_path

    File.open(file_path, "w") { |f| f.write(content) }
  end

  def folder dir
    FileUtils.mkdir_p "./#{@mvc_project_directory}/#{dir}/"
  end

  def add_compile_node folder, name
    proj_file = "#{@mvc_project_directory}/#{@mvc_project_directory}.csproj"
    doc = Nokogiri::XML(open(proj_file))
    doc.xpath("//xmlns:ItemGroup[xmlns:Compile]").first << "<Compile Include=\"#{folder.to_s}\\#{name}.cs\" />"
    File.open(proj_file, "w") { |f| f.write(doc) }
  end

  def add_cshtml_node folder, name
    proj_file = "#{@mvc_project_directory}/#{@mvc_project_directory}.csproj"
    doc = Nokogiri::XML(open(proj_file))
    doc.xpath("//xmlns:ItemGroup[xmlns:Content]").first << "<Content Include=\"Views\\#{folder}\\#{name}.cshtml\" />"
    File.open(proj_file, "w") { |f| f.write(doc) }
  end

def model_template name
return <<template
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Oak;

namespace #{@mvc_project_directory}.Models
{
    public class #{name} : DynamicModel
    {
        public #{name}(object dto) : base(dto) { }
        public #{name}() { }
        //IEnumerable<dynamic> Validates() { }
        //IEnumerable<dynamic> Associates() { }
    }
}
template
end

def controller_template name
return <<template
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Oak;

namespace #{@mvc_project_directory}.Controllers
{
    public class #{name} : BaseController { }
}
template
end

def repo_template name
return <<template
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Oak;
using Massive;

namespace #{@mvc_project_directory}.Repositories
{
    public class #{name} : DynamicRepository { }
}
template
end

def view_template name
return <<template
@{
    ViewBag.Title = "#{name}";
}
template
end
end
