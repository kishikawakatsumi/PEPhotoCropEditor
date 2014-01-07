DESTINATIONS = ["name=iPhone Retina (3.5-inch),OS=7.0",
                "name=iPhone Retina (4-inch),OS=7.0",
                "name=iPhone Retina (4-inch 64-bit),OS=7.0"]

desc 'Clean, Build'
task :default => [:clean, :build]

desc 'Clean'
task :clean do
  system("xcodebuild clean -scheme PEPhotoCropEditor | xcpretty -c")
end

desc 'Build'
task :build do
  system("xcodebuild -scheme PEPhotoCropEditor CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO | xcpretty -c")
end
