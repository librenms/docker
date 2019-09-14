## Add user

On first launch, an initial administrator user will be created :

| Login      | Password   |
|------------|------------|
| `librenms` | `librenms` |

You can create an other user using the commande line :

```text
$ docker-compose exec --user librenms librenms php adduser.php <name> <pass> 10 <email>
```

> :warning: Substitute your desired username `<name>`, password `<pass>` and email address `<email>`
