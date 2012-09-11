QuakeMapApp::Application.routes.draw do
  
  root to: "pages#home"
  
  post "/quakes" => "pages#show", as: :quakes
  
end
