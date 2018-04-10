## Generalities

This model is the representation of a simplified society in which three types
of building define the infractucture necessary for the interactions that occurs
between the three social groups. In this model the
economy is based on a single type of resource which represents all commodities,
this resources are produced by farmers in the first type of building named
farms, this buildings are assume as an infite source of income. This
resources are also used as currency to pay taxes in the second type of
building, named city hall, this building reseprent the government
institutions and store the supplys that are used to sustain soldiers,
which are in charge of seeking for the well being of the farmers by
keeping bandit population at bay. The last building type, named houses,
are used by farmers and bandits to store the spare resources that they
earn either by gathering them in a farm, in the case of farmers, or
stealing, in the case of bandits.

### Purpose

The purpose of the model is to analyse how delincuency affects the normal
development of a socity, from the effect that has in the workforce and how
reactions, like incrementing the public force angets, emerge as responce to
protect citizens from criminality.

### Entities and state variables
Entities

*  Farms: Provides an endless source of the necessary resources for the
population to subsist with.

*  Houses: Serves as an storage for the spare resources an indivial has
after using a portion of those to meet its needs. If a given individual
does not carry enought resources to refill its energy, they can use the
ones they have previously stored in their house.

*  City Hall: It stores the resources that farmers pay as taxes and also
the ones soldiers seize from bandits. Soldiers can use the funds in the
city hall to sustain themselves.

*  Farmers: They gather resources from farms and pay a certain amount of
those resources in the city hall as a way of paying soldiers for their
protection.

*  Bandits: Steal resources from farmers to sustain themselves while
trying to avoid soldiers.

*  Soldiers: Pursue bandits in order to reintegrate them into society as
farmers and recover the funds they have stolen.

State variables

The common atributes farmers, bandits and soldiers have are:

*  Energy: This serves as a way of telling of how much time an agent
have before it needs to eat and thus return to its home or in the case or
soldiers, city hall.

*  Load: It reprecents the quantity of resources a given agent is
carrying with itself at the moment.

*  Destination: This is the current destination a given agent seeks to
move towards to. In the case of farmers this can be their house, farm or
city hall. In the case of bandits this can be a possible farmer to rob or
their house. And finally it can be a nearby bandit or their city hall in
the case of soldiers.

Houses and City Halls share a common atribute named inventory which
is the amount of resources it is storing at the moment.

### Process overview and scheduling

Our procesess is divided in three parts, one for each social group. If the
agent is a farmer it will cycle through their assigned farm, city hall and
house. If the agent is a bandit will cycle trough, chasing after farmers trying
to assault them and going home. In the case of soldiers they loop over chasing
after bandits and going to their city hall. Finally on each tick all agents
will lose 1 unit of energy.

## Design concepts

### Basic principles

In this model it is supposed that the population is constant over time.  All
agents want to collect resources, each one in a different way depending on its
occupation. Also it is considered that there is a finite amount of weight and
energy that each individual can have. The spupply of resources available on
farms and the amount of resources that can be stored in a building is taken
as infinite. Finally each person has their own house.

### Emergence

There are many emergence behaviour in the model like the agglomeration of
agents in some parts of the map as a consequence of various farmers being
assigned to the same workplace. This attracts bandits thus incrementing the
criminality nearby this places and therefore making soldiers to appear in this
zones. Also the appearrance of sectors with a high dencity of bandits living in
it due to the remoteness that some places have from farms or city halls, making
the living as a farmer unsustainable.

### Adaptation

In the model agents adapt to their current situation if the conditions does not
provides enough resources to supply for a living by means of changing their
ocupation. It is important to notice that the social groups that an agent can
switch to depends on the occupation that they are currently performing.

### Objectives

The objective of an agent varies depending on their current occupation. Farmers
try to collect as much resources as they can by working their respective farms.
Bandits try to steal as much resources from farmers as they can, trying not to
be captured by soldiers. Finally soldiers seek to decreace the amount of
bandits in the society.

### Learning

Learning capabilities of agents are not taken into account in this model.

### Prediction

Prediction procedures are not taken into account as part of the agent's
behaviour in this model.

### Sensing

In this model bandits can know which farmers are currently carrying any resources
with themselves, they also search for nearby soldiers in order to be ready to
run away. In the case of soldiers they can know the position of the closest
bandit, so that they can chase after it. Also all agents are aware of the
location of the necessary buildings to carry out their occupation.

### Interaction

The model exhibit two types of interactions, one passive between members of the
social groups and the buildings, and the other one active between human agents
only. In the first case houses and city halls are used by active agents to
store their spare resources and farms are used by farmers to get the resources
they need for living. In the second case there are interactions between
bandits and the farmers they are going to steal from, and between soldiers and
the bandtis they are seeking to convert.

### Stochasticity

This model is present a stochastic behaviour due to the random initialization of
buildings and the introduction of a fix probability to determine the change of
occupation in the case of farmers to simulate the government support they have.

### Collectives

The model is define in terms of three major groups, farmers that represent
the productive class, bandits which represents the delinquency and soldiers
that represent control of the government in the society. The dynamic of the
system is define in terms of the interactions of these three groups.

### Observation

The variables that are necessary to know the current state of the system are
the population of each social group. The violence indicator, which is defined
in terms of the number of crimes committed in a specific location of the map.
Finally the capital that each group is currently possesing, which describes the
economical force and hence the success that the group has achived.

## Details

### Initialization

The model has 14 paramerters, the first nine correspond to the population,
energy and max load of each social group. Also there are two parameters in
charge of setting the amount of city halls and farms that the simulation will
have. Another parameter is the energy from food, that defines the amount of
energy recovered by each unit of resource. There is another parameter name tax
rate that establishes the tax fee that farmers have to pay in the city halls.
Finally the government support parameter is used as the probability that a
farmer has to choose to become a bandit or a soldier when the choise arrises.

At the begining of the simulation the position of all agents is chosen randomly
and all the parameters described above are used to determine the execution of
the simulation.

### Input

There is no input data used in the model.

### Submodels

*  Move: Is executed on each tick by all human agents, which
will make them move to their current destination and lose 1 unit of energy.
If they have no energy they will start consuming the resources they are
carrying at the moment to supply their lack of energy.

*  Rest: Is executed when an agent gets to
their resting place (houses in the case of bandits and farmers, and city
halls for soldiers) they will consume as much of the resources they
have at their disposal to refill their energy. Any remaining resources will
be stored in their resting place for later use. On the other hand, if they
do not have enough resources to do so, they will execute the
switch-occupation submodel.

*  Switch-occupation: This one is executed in a different way
depending on the agent occupation. In the case of farmers it will dicide if
the new occupation is to became a soldier or a bandit depending on the
government support. For both bandits and soldiers it will cause them to
switch occupation into farmers.

*  Work: This submodel is unique for farmers. When it is
executed they will extract resources from the farm they are currently in.
The amount of resources extracted will be equal to the max load they are
able to carry. Finally they will set their destination to the city hall to
pay-taxes.

*  Pay-taxes: This is also present only in farmers.
They will pay as much resources of the tax rate parameter as they can. If
they have less than the amount required they will give up all they
have. Whatever the amount of resources they are able to give, will be stored
in the city hall to pay for soldiers expenses. Lastly they will change
their destination to home in order to rest.

*  Assault: Only bandits are allowed to execute this submodel.
They will set their destination to the nearest farmer with non-zero load to
steal all of their belongings. In the case that there is a nearby soldier
they will prioritice moving away from them to avoid being caught. They
will continue to do so until either their energy hits zero or they get to the
maximum amount of load they are able to carry, and later set their detination
to their home in order to call the rest submodel.

*  Seize: Finally, this submodel is responsible to make
soldiers set their destination to the nearest bandit, if they get close
enought, they will make them execute the switch-occupation submodel. All
the resources bandits carry when they get caught are then seized by the
soldier. They will chase after bandits until either their energy hits zero
or they meet their maximum load, after which they will change their
destination to the city hall to rest.
