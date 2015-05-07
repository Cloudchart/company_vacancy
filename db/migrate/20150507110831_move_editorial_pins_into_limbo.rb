class MoveEditorialPinsIntoLimbo < ActiveRecord::Migration
  def up
    editor = Role.where(value: :editor, owner: nil).first.try(:user)

    if editor
      say 'Strarting to move editorial pins into limbo...'
      Pin.transaction do
        Pin.where('parent_id IS NULL AND pinnable_id IS NOT NULL AND content REGEXP BINARY ?', 'EDITORIAL').each do |pin|
          # trim keyword inside content
          content = pin.content.gsub(/EDITORIAL/, '').squish
          # create suggestion
          Pin.create(user: pin.user, parent: pin, pinnable: pin.pinnable, is_suggestion: true, author: editor)
          say 'suggestion created', true
          # put editorial pin into limbo
          pin.update(pinnable: nil, content: content, author: editor)
          say 'pin moved into limbo', true
        end
      end
    end
  end

  def down
    say 'Nothing to be done'
  end
end
