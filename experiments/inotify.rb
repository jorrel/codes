require 'inotify'

i = Inotify.new

$files = [
  '/home/jorrel/Tmp/lcm.rb',
  '/home/jorrel/Tmp/tmp.tmp'
]

$files.each { |file| i.add_watch(file, Inotify::ALL_EVENTS) }

# Inotify::MODIFY => modified
# Inotify::MOVE_SELF => moved / renamed
# Inotify::ATTRIB => attribute changed
#
# Inotify::DELETE
# Inotify::DELETE_SELF   => deleted
# events_watched = Inotify::OPEN ^ Inotify::MODIFY
# files.each { |file| i.add_watch(file, events_watched) }




def mask_to_constant_name(mask)
  if m = Inotify.constants.detect { |c| Inotify.const_get(c) == mask }
    "Inotify::#{m}"
  end
end

def which_file(wd)
  $files[wd - 1]
end

i.each_event do |event|
  puts "\nevent catched:"
  puts event.inspect
  puts "name: #{event.name}"
  puts "mask: #{event.mask} (#{mask_to_constant_name(event.mask)})"
  puts "wd  : #{event.wd} (#{which_file(event.wd)})"
end

