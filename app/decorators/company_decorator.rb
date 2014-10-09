class CompanyDecorator < ApplicationDecorator
  decorates :company

  def name
    company.name.present? ? company.name : 'Unnamed'
  end

  def og_name
    prefix = company.name == 'CloudChart' ? '' : 'CloudChart: '
    "#{prefix}#{company.name}"
  end

  def tags
    company.tags.map { |tag| "##{tag.name}" }.join(', ')
  end

  def logo
    if company.logotype
      image_tag(company.logotype.url)
    else
      content_tag :figure, style: "background-color: #{color(self.name)};" do
        initials
      end
    end  
  end


private

  # TODO get rid of dublicity
  def initials
    name = self.name

    uppercasedLetters = name.split('').select do |letter, i|
      letter != ' ' and letter == letter.upcase
    end.join('')

    initialLetters = name.split(' ').map { |part| part[0] }.join('')

    result = if uppercasedLetters.length >= 2 then uppercasedLetters
    elsif initialLetters.length >= 2 then initialLetters
    else name
    end

    result[0...2].upcase
  end

  def color(name)
    color_index = name.split('').inject(0) do |memo, letter|
      memo += letter.ord
    end % placeholder_colors.length
  
    placeholder_colors[color_index]
  end

  def placeholder_colors
    [
      'hsl( 39, 85%, 71%)',
      'hsl(141, 46%, 59%)',
      'hsl(196, 91%, 69%)',
      'hsl( 25, 80%, 67%)',
      'hsl(265, 55%, 76%)',
      'hsl(344, 88%, 76%)',
      'hsl( 84, 75%, 75%)',
      'hsl(229, 75%, 72%)',
      'hsl( 59, 76%, 76%)',
      'hsl(144, 75%, 75%)',
      'hsl(359, 57%, 76%)',
      'hsl(206, 57%, 76%)'
    ]
  end  

end
