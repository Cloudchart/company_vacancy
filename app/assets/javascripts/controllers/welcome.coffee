@['welcome#index'] = (data) ->

  if data.chart_id and chartPreviewMountPoint = document.querySelector('[data-react-chart-preview-mount-point]')
    ChartPreviewComponent = cc.require('blueprint/react/chart-preview')
  
    chartPreview = ChartPreviewComponent({ id: data.chart_id, scale: 1 })

    React.renderComponent(chartPreview, chartPreviewMountPoint)
  
  
  if modalMountPoint = document.querySelector('[data-modal-mount-point]')
    ModalComponent = cc.require('react/shared/modal')
    React.renderComponent(ModalComponent({}), modalMountPoint)

    if (loginButton = document.querySelector('[data-behaviour~="login-button"]')) and (LoginForm = cc.require('react/modals/login-form'))
      loginButton.addEventListener 'click', (event) ->
        event.preventDefault()
        
        event = new CustomEvent 'modal:push',
          detail:
            component: LoginForm({})

        window.dispatchEvent(event)
