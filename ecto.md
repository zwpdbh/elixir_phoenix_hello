# Ecto 
## The schema (model) we want 
- `Tag`
  - tag_name
  
- `StorageType` 
  - managed_disk
  - nvme  
  - SAN 

- `Cluster`
  - aks_name
  - resource_group
  - region
  - subscription_id
  - storage_type (refer to StorageType)

- `Pod`
  - pod_name
  - aks_id (refer to a Cluster)

- `JobStatus`
  - StatusName
    - NotStaredYet
    - InProgress
    - Success
    - Error 

- `DeployClusterJob`
  - aks_name 
  - resource_group
  - region
  - subscription
  - storage_type (refer to StorageType)
  - log_to
  - JobStatus_id (refer to a JobStatus)
  - OtherInfo (could be json encoded string)

- `ScenarioTestJob`
  - sceanrio_name 
  - case_name
  - pod_id (refer to a Pod)
  - log_to 
  - JobStatus_id (refer to a JobStatus)
  - OtherInfo (could be json encoded string)
  



## Generate table by using ecto migration 
### Define JobStatus
- prepare migration 
  ```sh 
  mix ecto.gen.migration create_job_status
  ```
- define migration 
  ```elixir
  defmodule AzStore.Repo.Migrations.CreateJobStatus do
    use Ecto.Migration

    def change do
      create table(:job_status) do
        add :status, :string
      end
    end
  end
  ```
- do the migration 
  ```sh
  mix ecto.migrate 
  ```

### Define StorageTypes 
Did similar thing as job_status 
- Run `mix ecto.gen.migration create_storage_types`
- Edit generated .exs file 
  ```elixir
  defmodule AzStore.Repo.Migrations.CreateStorageTypes do
    use Ecto.Migration

    def change do
      create table(:storage_type) do
        add(:name, :string)
      end
    end
  end
  ```
- Run `ecto.migrate`

### Define Aks cluster 
- `mix ecto.gen.migration create_cluster`
- A cluster must belong to one of storage type. 
  ```elixir 
  defmodule AzStore.Repo.Migrations.CreateCluster do
    use Ecto.Migration

    def change do
      create table(:cluster) do
        add :name, :string
        add :resource_group, :string
        add :region, :string
        add :subscription, :string
        add :storage_type_id, references("storage_type")
      end
    end
  end
  ```
- `mix ecto.migrate`

### Define Pod 
- Create table 
  ```elixir 
  defmodule AzStore.Repo.Migrations.CreatePod do
    use Ecto.Migration

    def change do
      create table(:pod) do
        add :name, :string
      end
    end
  end
  ```
- I forget to add references to cluster, just create another migration 
  ```elixir 
  defmodule AzStore.Repo.Migrations.ModifyPod do
    use Ecto.Migration

    def change do
      alter table("pod") do
        add(:cluster_id, references("cluster"))
      end
    end
  end
  ```

### Define DeployClusterJob
```elixir 
defmodule AzStore.Repo.Migrations.CreateDeployClusterJobs do
  use Ecto.Migration

  def change do
    create table(:deploy_cluster_job) do
      add(:name, :string)
      add(:resource_group, :string)
      add(:region, :string)
      add(:subscription, :string)
      add(:storage_type_id, references("storage_type"))
      add(:log_to, :string)
      add(:job_status, references("job_status"))
      add(:other_info, :string)
    end
  end
end
```

### Define `ScenarioTestJob`
```elixir 
defmodule AzStore.Repo.Migrations.CreateScenarioTestJobs do
  use Ecto.Migration

  def change do
    create table(:scenario_test_job) do
      add(:scenario_name, :string)
      add(:case_name, :string)
      add(:on_pod, references("pod"))
      add(:start_time, :utc_datetime)
      add(:end_time, :utc_datetime, null: true)
      add(:log_to, :string)
      add(:job_status, references("job_status"))
      add(:other_info, :string)
    end
  end
end
```

## Create schema to map between model and table entry


# References 
## Tutorials 
- [ ] [Get started](https://hexdocs.pm/ecto/getting-started.html)
- [ ] [Ecto: An Introduction to Elixir's Database Toolkit](https://serokell.io/blog/ecto-guide-for-beginners)
## Questions  
- [How to store array with Ecto using Postgres](https://stackoverflow.com/questions/33065318/how-to-store-array-with-ecto-using-postgres)


# Things have learned
## Create data store (add ecto to application)
- `mix ecto.gen.repo -r Friends.Repo`
  - Generate 2 files 
    - `lib/friends/repo.ex` defines database adapter.
      - Its `otp_app` defines which database configuration it can look for in the configuration. For example, `:friends`.
      - `Friends.Repo` is the database we will be used to interact with our schema. 
    - `config/config.exs` defines how to connect to database. 
      - It give the name `:friends` to a configuration. 
  - In general, it defines and create data store for a database.
- Set application to supervise Ecto process by providing `Friends.Repo` module defined in the children spec.
- Tell application abount the repo in `config/config.exs`. It allow us to run commands such as `mix ecto.create`.

## Setting up database 
- Create the database by `mix ecto.create`
- Create table by ecto's migration
  - `mix ecto.gen.migration create_people`
    - The result of it is a migration file in folder `priv/repo/migrations`, we need to fill it with `change`
    - Here, in the `change` we define `create table` add define new fields.
      ```elixir 
      defmodule Friends.Repo.Migrations.CreatePeople do
      use Ecto.Migration

        def change do
          create table(:people) do
            add :first_name, :string
            add :last_name, :string
            add :age, :integer
          end
        end
      end
      ```
    - The types of those fields see: [Ecto.Schema](https://hexdocs.pm/ecto/Ecto.Schema.html)
  - Run `mix ecto.migrate` will create the table in database.
  
- Alter table 
  - For example, the column `:age` is accidentially write to `:agen`. We need to alter the table column. 
    - Generate migration file 
      ```shell
      mix ecto.gen.migration alter_people
      * creating priv/repo/migrations/20230427073822_alter_people.exs
      ```
    - Edit the `priv/repo/migrations/20230427073822_alter_people.exs`
      ```elixir 
      defmodule Friends.Repo.Migrations.AlterPeople do
        use Ecto.Migration

        def change do
          rename table(:people), :agen, to: :age
        end
      end
      ``` 
    - Run `mix ecto.migrate`.
  - See different migrations functions at: [Ecto.Migration](https://hexdocs.pm/ecto_sql/Ecto.Migration.html#functions).
  
## [Create the schema](https://hexdocs.pm/ecto/getting-started.html#creating-the-schema)
- A schema is a Elixir representation of data from our database. It is commonly associated with a database table (or a database view).
- Create a schema (for a model) in `lib/<app_name>/<schema_name>.ex`
  - Such as `lib/friends/person.ex`
    ```elixir 
    defmodule Friends.Person do
      use Ecto.Schema

      schema "people" do
        field :first_name, :string
        field :last_name, :string
        field :age, :integer
      end
    end
    ```
    - It maps a elixir structure into a row in corresponding table.
    - It looks identical to our table migration because the table is a fresh created one. Notice a migrate can come with changes to an existing table.
  
## Interact with our data 
  ```elixir 
  person = %Friends.Person{}
  # Here we insert the data directly without validation
  {:ok, person} = Friends.Repo.insert(person)
  ```

## Validate changes using [Ecto.Changeset](https://hexdocs.pm/ecto/Ecto.Changeset.html)
- Validate changes before insert data into database.
- Define changeset in the schema file (it will hold represent our model including attributes and constraits)
  ```Elixir 
  def changeset(person, params \\ %{}) do
    person
    |> Ecto.Changeset.cast(params, [:first_name, :last_name, :age])
    |> Ecto.Changeset.validate_required([:first_name, :last_name])
  end
  ```
- Now, instead insert a module directly we let it first goes through changeset
  ```elixir 
  person = %Friends.Person{}
  changeset = Friends.Person.changeset(person, %{})

  case Friends.Repo.insert(changeset) do
    {:ok, person} ->
      # do something with person
    {:error, changeset} ->
      # do something with changeset
      traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
  end
  ```
  - The above example is from: [Validating changes](https://hexdocs.pm/ecto/getting-started.html#validating-changes) 

## Query to fetch, update and delete 
- In general, it needs two steps 
  - Construct the query.
  - Execute the query against the database by passing it to the repo.
- Fetching a single record 
  - Automatically, 
    ```elixir
    Friends.Person |> Ecto.Query.first
    ```
  - Manually
    ```elixir
    require Ecto.Query
    Ecto.Query.from p in Friends.Person, order_by: [asc: p.id], limit: 1
    ```

- Here are some examples (more examples see [Basic CRUD](https://hexdocs.pm/ecto/crud.html))
  ```elixir
  def demo_query_one_v1 do
    Friends.Person |> Ecto.Query.first() |> Friends.Repo.one()
  end

  def demo_query_one_v2 do
    Ecto.Query.from(p in Friends.Person, order_by: [asc: p.id], limit: 1) |> Friends.Repo.one()
  end

  def demo_query_all do
    Friends.Person |> Friends.Repo.all()
  end

  def demo_query_with_id do
    Friends.Person |> Friends.Repo.get(1)
  end

  def demo_query_with_value do
    Friends.Person |> Friends.Repo.get_by(first_name: "Ryan")
  end

  def demo_filter_results_v1 do
    last_name = "Smith"
    Friends.Person |> Ecto.Query.where(last_name: ^last_name) |> Friends.Repo.all()
  end

  def demo_filter_results_v2 do
    last_name = "Smith"
    Ecto.Query.from(p in Friends.Person, where: p.last_name == ^last_name) |> Friends.Repo.all()
  end

  def demo_query_compose do
    Friends.Person
    |> Ecto.Query.where(last_name: "Smith")
    |> Ecto.Query.where(first_name: "Jane")
  end

  def demo_update do
    Friends.Person
    |> Ecto.Query.first()
    |> Friends.Repo.one()
    # After fetch a record we create a changeset
    |> Friends.Person.changeset(%{age: 29})
    # Then, call update
    |> Friends.Repo.update()
  end

  def demo_delete do
    Friends.Repo.get(Friends.Person, 1) |> Friends.Repo.delete()
  end 
  ```
  
## [Embedded Schemas](https://hexdocs.pm/ecto/embedded-schemas.html) 
- Basically it is to use Ecto for moduling data and validation without rely on a serious database.
  - For example, if you want to build a contact form, you still want to parse and validate the data, but the data is likely not persisted anywhere. Instead, it is used to send an email. Embedded schemas would be a good fit for such a use case.
- Another scenario to use it is to store extra information along side a schema. However, the information we want to store and validate is not that important or will be changed frequently in the future.   

## Test Ecto 
1. Define `config/test.exs`.
    - Config the database connection for test setup. 
2. Modify `config/config.exs`
    - Add an explicit statement about `sandbox` model in `test/test_helper.exs`.
3. Establish the database connection ahead of your tests
    - Define template by extending the `ExUnit` template. 
    - Or setting it up indivisually for each test.
4. Use the template or setup in each test in each test files.(See: [friends_test.exs](https://github.com/zwpdbh/learn-ecto/blob/master/test/friends_test.exs))

## How to re-create the database and tables 
Here is the steps we re-initialize db with tables ready.
```
mix ecto.drop
mix ecto.create
mix ecto.migrate
```

## References
### Ecto Associations 
- [Ecto Associations](https://hexdocs.pm/ecto/2.2.11/associations.html)
- [Ecto Associations in Phoenix LiveView: One to Many](https://dennisbeatty.com/ecto-associations-in-phoenix-liveview-one-to-many/)
  
### Associations in Changeset 
- [Understanding Associations in Elixir's Ecto](https://blog.appsignal.com/2020/11/10/understanding-associations-in-elixir-ecto.html)
- [StackOverflow -- How to set a belong_to association in a changeset](https://stackoverflow.com/questions/39105550/elixir-ecto-how-to-set-a-belongs-to-association-in-a-changeset)

### General rules 
- How to decide "belongs_to" 
  - If table A have a foreign key to table B, then we say table A "belongs to" table B.
  - For example, one user has one avatar and one avatar belongs to one user. 
    - The difference between has_one and belongs_to is where the primary key belongs. 
    - In this case, we want the “avatars” table to have a “user_id” columns, therefore the avatar belongs to the user.

### Other post about many-to-many and belong-to relationship  
- How do we define many-to-many in ecto ? (see: [The right way — Use Ecto powers](https://medium.com/coletiv-stories/ecto-elixir-many-to-many-relationships-66403933f8c1))
  - It uses: `put_assoc/4`
- Belong-to and has-many, see [Ecto belongs_to and has_many](https://alchemist.camp/episodes/ecto-beginner-basic-associations)
- [Building Many-To-Many Associations with Embedded Schemas in Ecto and Phoenix](https://medium.com/@abitdodgy/building-many-to-many-associations-with-embedded-schemas-in-ecto-and-phoenix-e420abc4c6ea)


  

## Summary 
- Define and connect our datastore (repo).
- Define database table by using ecto migration.
- In schema: 
  - Represent our model and map it to table entry.
  - Define model validation in schema.
- CRUD model 
  - First, construct query 
  - Then, execute it against our repo.


## Others 
- [StackOverflow -- Creating a unique constraint on two columns together in Ecto](https://stackoverflow.com/questions/36418223/creating-a-unique-constraint-on-two-columns-together-in-ecto)