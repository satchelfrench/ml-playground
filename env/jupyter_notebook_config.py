# file must be moved from host to contianer at the following path:
# /root/.jupyter/jupyter_notebook_config.py

c.NotebookApp.allow_root = True
c.NotebookApp.password = u'your-hashed-password'
c.NotebookApp.open_browser = False
c.NotebookApp.port = 4000 # or any other port you configure
c.NotebookApp.ip = "0.0.0.0"
