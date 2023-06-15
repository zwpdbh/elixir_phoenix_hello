# How to deploy to Azure 

## General Knowledge about Elixir Phoenix Application 



## General Steps 

- Use docker-compose doing build and test 
  - We could do this manually in local or automate it from CI/CD pipeline. 
  - An example of doing this in [Azure DevOps using CI/CD pipeline](https://dev.to/behnam/azuredevops-elixir-docker-ci-cd-and-the-others-part-1-docker-compose-and-testing-o1m).

- Deploy app to an app service in Azure by using `release` in elixir and a docker image. 
  - Create Azure container registry.
  - Create a Postgres Server
  - Build and Push 


## References 

- [Introduction to Phoenix Deployment](https://hexdocs.pm/phoenix/deployment.html#content)
- [Deploying with Mix Releases](https://hexdocs.pm/phoenix/releases.html)