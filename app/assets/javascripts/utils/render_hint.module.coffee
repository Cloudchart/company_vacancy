# @cjsx React.DOM
#

Hints =
  quote:   
    text: "A short, eye-catching tweeteable quote by someone from the company, an outside opinion by a person or a media."
    
  title: 
    text: "A concise, impartial, and clear fact: what happened?"
  
  date: 
    text: "If there's no exact date, keep the month and year only."

  paragraph:
    text: "Tell a short single-minded fact-checked story."
  
  stories:
    render: ->
      <div>
        Pick one or more categories:
        <ul>
          <li>Leadership: key people coming/leaving the company</li>
          <li>Product: everything product-related, including pivots</li>
          <li>Growth: quantitative growth/churn, new hires/layoffs, company acquisitions/sales, branches opening/closing etc</li>
          <li>Traction: quantitative evidence of market demand</li>
          <li>Funding: company value, series A/B/C etc investment rounds, etc.</li>
        </ul>
      </div>

module.exports = (hintKey) ->
  hint = Hints[hintKey]

  return null if !hint

  if text = Hints[hintKey].text
    <span>{ text }</span>
  else
    Hints[hintKey].render()