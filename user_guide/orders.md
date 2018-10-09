# Working with Orders

An Order represents a request for materials for use by one or more people at a specific location (e.g. a researcher using materials in a reading room).

An Order must include one or more Items, which, be default, represent requestable top containers created in ArchivesSpace.

## The Order workflow

By default, Orders are tracked through 5 workflow states, described below.

In addition to the Order workflow, each Item associated with the Order has its own workflow and states. The Item and Order workflows are separate but not completely independent. Some states within the Order workflow are dependent upon the states of its associated items, and some states in the Item workflow are dependent on the Order state.

### Order workflow states

1. **pending** - The Order has been created and needs to be reviewed
2. **reviewing** - The Order is in the process of being reviewed (this step can be skipped, moving directly to the 'confirmed' state)
3. **confirmed** - The Order has been confirmed and the requested Items can be transferred from their storage location for use
4. **fulfilled** - All of the Items associated with this Order have been transferred to their use location (this state is reached automatically once all Items have been marked as received for use; the user cannot move to this state manually without administrative override)
5. **closed** - All of the Items associated with this Order have been returned to their permanent locations (this state is reached automatically once all Items have been marked as returned; the user cannot move to this state manually without administrative override)

## Orders list

The first view available is a list of all Orders in the system. Each record int he list provides an overview of the Order. Clicking the 'View' link will display details of the Order and provide

## Create a new Order

From the Orders list view, clicking the "Create new order" link at the top will take you to a form where you may create an Order.

### Select Order type

Each order must be assigned an Order type. The default types are:

1. research access (individual)
2. course reserve
3. duplication
4. preservation treatment
5. exhibition
6. special loan
7. processing
8. digitization
9. staff use

### Add researchers (users)

Each Order must be associated with one ore more researchers (users). Existing users can be selected by typing their name or email address in the text box provided and selecting the correct user from the results that appear.

Alternately, a new user can be created directly from the Order form. See the Users page of this guide for more information.

### Add Items

### Specify use location

### Selecting


## Editing an existing Order
