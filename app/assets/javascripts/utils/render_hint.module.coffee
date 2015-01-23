# @cjsx React.DOM
#

Hints =
  quote:   
    text: "A short, eye-catching tweeteable quote by someone from the company, an outside opinion by a person or a media."
    
  title: 
    text: "A concise, impartial, and clear fact: what happened?"
  
  date: 
    text: "If there's no exact date, keep the month and year only."
  
  stories:
    render: ->
      <div>
        Pick one category:
        <ul>
          <li>Leadership: key people coming/leaving the company;</li>
          <li>Product: everything product-related, including pivots;</li>
          <li>Growth: quantitative growth/churn, new hires/layoffs, company acquisitions/sales, branches opening/closing etc;</li>
          <li>Traction: quantitative evidence of market demand;</li>
          <li>Funding: company value, series A/B/C etc investment rounds, etc.</li>
        </ul>
      </div>
  
  tags:
    text: "Use general hashtags like #automotive, #hire, #marketing, and company-specific hashtags like #macbook. Usually 3-5 hashtags are enough."

module.exports = (hintKey) ->
  hint = Hints[hintKey]

  return null if !hint

  if text = Hints[hintKey].text
    <span>{ text }</span>
  else
    Hints[hintKey].render()