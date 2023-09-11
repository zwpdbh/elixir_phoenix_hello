defmodule Hello.Thermostat do
    def get_user_reading(nil) do
    {:error, "uuid must be set for a user"}
  end
  def get_user_reading(_user_id) do
    {:ok, Enum.random(0..40)}
  end
end
