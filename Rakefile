DESTINATIONS = ["name=iPhone Retina (3.5-inch),OS=7.0",
                "name=iPhone Retina (4-inch),OS=7.0",
                "name=iPhone Retina (4-inch 64-bit),OS=7.0"]

desc 'Clean and Build'
task :default => [:clean, :build]

desc 'Clean'
task :clean do
  sh "xcodebuild clean -scheme PEPhotoCropEditor | xcpretty -c; exit ${PIPESTATUS[0]}"
end

desc 'Build'
task :build do
  sh "xcodebuild -scheme PEPhotoCropEditor CODE_SIGN_IDENTITY=\"\" CODE_SIGNING_REQUIRED=NO | xcpretty -c; exit ${PIPESTATUS[0]}"
end
